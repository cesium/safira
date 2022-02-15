defmodule Mix.Tasks.Export.Daily.Stats do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Store
  alias Safira.Roulette
  alias Safira.Repo
  import Ecto.Query

  def run(date) do
    Mix.Task.run("app.start")

    badges = get_badges_global()
    Mix.shell.info("badges: #{badges}")
    entries = get_nr_final_entries()
    Mix.shell.info("entries: #{entries}")
    tks = get_nr_tokens_atr()
    Mix.shell.info("tokens earned: #{tks}")
    spent = get_spent_tokens()
    Mix.shell.info("tokens spent: #{spent}")
    prizes = get_roulette_prizes_global()

    prizes
    |> Enum.map(fn entry ->
      entry
      |> Enum.map(fn e ->
        Mix.shell.info("prize: #{e}")
      end)
    end)
  end

  # # badges atribuidos
  defp get_nbadges(date) do
    Repo.all(from r in Safira.Contest.Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and fragment("?::date", r.inserted_at) == ^date and b.type != ^0,
      select: count(r.id))
      |> Enum.reduce(0, &(&1 + &2))
  end

  # # of badges overall
  defp get_badges_global() do
    Repo.all(from r in Safira.Contest.Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and  b.type != ^0,
      select: count(r.id))
      |> Enum.reduce(0, &(&1 + &2))
  end

  # # of entries to the final draw
  # global
  defp get_nr_final_entries() do
    Repo.all(
      from a in Safira.Accounts.Attendee,
      select: sum(a.entries)
    )
    |> Enum.reduce(0, &(&1 + &2))
  end

  # tokens atribuidos
  # global in the system + nr os tokes spent
  defp get_nr_tokens_atr() do
    total =
      Repo.all(
        from a in Safira.Accounts.Attendee,
        select: sum( a.token_balance )
      )
      |> Enum.reduce(0, &(&1 + &2))
    get_spent_tokens()+total
  end

  # # of tokens spent globaly
  # count nr os roullete rolls * 20
  # count nr sales (by total token ammount)
  defp get_spent_tokens() do
    spent_roulette =
      Repo.all(
        from ap in Safira.Roulette.AttendeePrize,
        select: count(ap.id) * 20
      )
      |> Enum.reduce(0, &(&1 + &2))
    spent_store =
      Repo.all(
        from r in Safira.Store.Redeemable,
          join: b in Safira.Store.Buy, on: r.id == b.redeemable_id,
          select: sum(r.price * b.quantity)
      )
      |> Enum.reduce(0, &(&1 + &2))
    spent_roulette + spent_store

  end

  # premios ganhos na roleta
  # SHOULD WORK
  # daily task
  defp get_roulette_prizes(date) do
     Repo.all(
      from a in Safira.Accounts.Attendee,
        join: ap in Safira.Roulette.AttendeePrize, on: a.id == ap.attendee_id,
        join: p in Safira.Roulette.Prize, on: ap.prize_id == p.id,
        where: not (is_nil a.user_id) and fragment("?::date", ap.inserted_at) == ^date,
        select: %{prize: p.name, number: count(p.id) }
     )
  end

  # premios ganhos na roleta
  # SHOULD WORK
  # global task
  defp get_roulette_prizes_global() do
     Repo.all(
      from p in Safira.Roulette.Prize,
        join: ap in Safira.Roulette.AttendeePrize, on: p.id == ap.prize_id,
        group_by: p.id,
        select: %{id: p.id, prize: p.name, number: count(ap.id) }
     )
  end
end
