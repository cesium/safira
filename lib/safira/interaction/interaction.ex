defmodule Safira.Interaction do
  @moduledoc """
  The Interaction context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Interaction.Bonus
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Company
  alias Safira.Interaction.Spotlight
  alias Safira.Contest.DailyToken
  alias Ecto.Multi

  @doc """
  Returns the list of bonuses.

  ## Examples

      iex> list_bonuses()
      [%Bonus{}, ...]

  """
  def list_bonuses do
    Repo.all(Bonus)
  end

  @doc """
  Gets a single bonus.

  Raises `Ecto.NoResultsError` if the Bonus does not exist.

  ## Examples

      iex> get_bonus!(123)
      %Bonus{}

      iex> get_bonus!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bonus!(id), do: Repo.get!(Bonus, id)

  @doc """
  Gets Bonus given attendee_id and company_id.
  """
  def get_keys_bonus(attendee_id, company_id) do
    Repo.get_by(Bonus, attendee_id: attendee_id, company_id: company_id)
  end

  @doc """
  Creates a bonus.

  ## Examples

      iex> create_bonus(%{field: value})
      {:ok, %Bonus{}}

      iex> create_bonus(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bonus(attrs \\ %{}) do
    %Bonus{}
    |> Bonus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bonus.

  ## Examples

      iex> update_bonus(bonus, %{field: new_value})
      {:ok, %Bonus{}}

      iex> update_bonus(bonus, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bonus(%Bonus{} = bonus, attrs) do
    bonus
    |> Bonus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Bonus.

  ## Examples

      iex> delete_bonus(bonus)
      {:ok, %Bonus{}}

      iex> delete_bonus(bonus)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bonus(%Bonus{} = bonus) do
    Repo.delete(bonus)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bonus changes.

  ## Examples

      iex> change_bonus(bonus)
      %Ecto.Changeset{source: %Bonus{}}

  """
  def change_bonus(%Bonus{} = bonus) do
    Bonus.changeset(bonus, %{})
  end

  def give_bonus(attendee, company) do
    Multi.new()
    # get or build a bonus
    |> Multi.run(:get_bonus, fn _repo, _changes ->
      {:ok,
       get_keys_bonus(attendee.id, company.id) ||
         %Bonus{attendee_id: attendee.id, company_id: company.id, count: 0}}
    end)
    # update the bonus count
    |> Multi.insert_or_update(:upsert_bonus, fn %{get_bonus: bonus} ->
      Bonus.changeset(bonus, %{count: bonus.count + 1})
    end)
    # update attendee's token_balance
    |> Multi.update(
      :update_attendee,
      Attendee.update_token_balance_changeset(attendee, %{
        token_balance: attendee.token_balance + Application.fetch_env!(:safira, :token_bonus)
      })
    )
    |> Multi.insert_or_update(:daily_token, fn %{update_attendee: attendee} ->
      {:ok, date, _} = DateTime.from_iso8601("#{Date.utc_today()}T00:00:00Z")

      DailyToken.changeset(%DailyToken{}, %{
        quantity: attendee.token_balance,
        attendee_id: attendee.id,
        day: date
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns the only existing Spotlight
  """
  def get_spotlight() do
    Repo.all(Spotlight) |> List.first()
  end

  @doc """
  Starts the spotlight
  """
  def start_spotlight(company) do
    Multi.new()
    # get or build a spotlight
    |> Multi.run(:get_spotlight, fn _repo, _changes ->
      {:ok,
       get_spotlight() ||
         %Spotlight{}}
    end)
    # update the spotlight
    |> Multi.insert_or_update(:upsert_spotlight, fn %{get_spotlight: spotlight} ->
      Spotlight.changeset(spotlight, %{badge_id: company.badge_id, active: true})
    end)
    # update company's remaining_spotlights
    |> Multi.update(
      :update_company,
      Company.start_spotlight_changeset(
        company,
        %{remaining_spotlights: company.remaining_spotlights - 1}
      )
    )
    |> apply_transaction()
  end

  @doc """
  Signals spotlight as inactive
  """
  def finish_spotlight() do
    get_spotlight()
    |> Spotlight.finish_changeset(%{active: false})
    |> Repo.update()
  end

  def is_badge_spotlighted(badge_id) do
    spotlight = get_spotlight()

    !is_nil(spotlight) and spotlight.active and spotlight.badge_id == badge_id
  end

  defp apply_transaction(multi) do
    try do
      Repo.transaction(fn ->
        Repo.transaction(multi)
        |> case do
          {:ok, result} ->
            result

          {:error, _failed_operation, changeset, _changes_so_far} ->
            # That's the way to retrieve the changeset as a value
            Repo.rollback(changeset)
        end
      end)
    rescue
      _ ->
        # Transaction may raise Ecto.StaleEntryError when optimistic locking fails
        apply_transaction(multi)
    end
  end
end
