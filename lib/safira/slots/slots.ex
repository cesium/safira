defmodule Safira.Slots do
  @moduledoc """
  The Slots context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi

  alias Safira.Repo

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.DailyToken
  alias Safira.Slots.AttendeePayout
  alias Safira.Slots.Payout

  @doc """
  Creates a payout.

  ## Examples

      iex> create_payout(%{field: value})
      {:ok, %Payout{}}

      iex> create_payout(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payout(attrs \\ %{}) do
    %Payout{}
    |> Payout.changeset(attrs)
    |> Repo.insert()
  end

  def spin(attendee, bet) do
    spin_transaction(attendee, bet)
    |> case do
      {:error, :attendee_state, changeset, data} ->
        if Map.get(get_errors(changeset), :token_balance) != nil do
          {:error, :not_enough_tokens}
        else
          {:error, :attendee, changeset, data}
        end

      result ->
        result
    end
  end

  @doc """
  Transaction that takes a number of tokens bet by an attendee,
  and applies a probability-based function for "spinning the reels on a slot machine"
  that calculates a payout and then updates the attendee's token balance.
  """
  def spin_transaction(attendee, bet) do
    Multi.new()
    # remove the bet from the attendee's token balance
    |> Multi.update(
      :attendee_state,
      Attendee.update_token_balance_changeset(attendee, %{
        token_balance: attendee.token_balance - bet
      })
    )
    # generate a random payout
    |> Multi.run(:payout, fn _repo, _changes -> {:ok, generate_spin()} end)
    # calculate the tokens (if any)
    |> Multi.run(:tokens, fn _repo, %{payout: payout} ->
      {:ok, (bet * payout.multiplier) |> round}
    end)
    # log slots result for statistical purposes
    |> Multi.insert(:attendee_payout, fn %{payout: payout, tokens: tokens} ->
      %AttendeePayout{}
      |> AttendeePayout.changeset(%{
        attendee_id: attendee.id,
        payout_id: payout.id,
        bet: bet,
        tokens: tokens
      })
    end)
    # update user tokens based on the payout
    |> Multi.update(:attendee, fn %{attendee_state: attendee, tokens: tokens} ->
      Attendee.update_token_balance_changeset(attendee, %{
        token_balance: attendee.token_balance + tokens
      })
    end)
    # update the daily token count for leaderboard purposes
    |> Multi.insert_or_update(:daily_token, fn %{attendee: attendee} ->
      {:ok, date, _} = DateTime.from_iso8601("#{Date.utc_today()}T00:00:00Z")
      changeset_daily = Contest.get_keys_daily_token(attendee.id, date) || %DailyToken{}

      DailyToken.changeset(changeset_daily, %{
        quantity: attendee.token_balance,
        attendee_id: attendee.id,
        day: date
      })
    end)
    |> Repo.transaction()
  end

  # Generates a random payout, based on the probability of each multiplier
  defp generate_spin do
    random = strong_randomizer() |> Float.round(12)

    payouts =
      Repo.all(Payout)
      |> Enum.filter(fn x -> x.probability > 0 end)

    cumulative_prob =
      payouts
      |> Enum.map_reduce(0, fn payout, acc ->
        {Float.round(acc + payout.probability, 12), acc + payout.probability}
      end)

    cumulatives =
      cumulative_prob
      |> elem(0)
      |> Enum.concat([1])

    sum =
      cumulative_prob
      |> elem(1)

    remaining_prob = 1 - sum

    real_payouts = payouts ++ [%{multiplier: 0, probability: remaining_prob, id: nil}]

    prob =
      cumulatives
      |> Enum.filter(fn x -> x >= random end)
      |> Enum.at(0)

    real_payouts
    |> Enum.at(
      cumulatives
      |> Enum.find_index(fn x -> x == prob end)
    )
  end

  # Generates a random number using the Erlang crypto module
  defp strong_randomizer do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsplus, {i1, i2, i3})
    :rand.uniform()
  end

  defp get_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
