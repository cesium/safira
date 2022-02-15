defmodule Mix.Tasks.Export.Daily.Stats do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Store
  alias Safira.Roulette

  def run(date) do
    Mix.Task.run("app.start")

    badges = get_nbadges()
    entries = get_nr_final_entries()
    tks = get_nr_tokens_atr()
    spent = get_spent_tokens()
    prizes = get_roulette_prizes()

    Mix.shell.info("badges: #{badges}")
    Mix.shell.info("entries: #{entries}")
    Mix.shell.info("tokens earned: #{tks}")
    Mix.shell.info("tokens spent: #{spent}")

    Enum.map(prizes, fn entry ->
      Mix.shell.info("prize: #{entry}")
      end )
  end

  # # badges atribuidos
  defp get_nbadges(date) do
    Repo.all(from r in Safira.Store.Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and fragment("?::date", r.inserted_at) == ^date and b.type != ^0 and fragment("?::date", t.day) == ^date,
      select: count(r.id),
      preload: [badge: b, attendee: a])
  end

  # # of badges overall
  defp get_badges_global do
    Repo.all(from r in Safira.Store.Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and  b.type != ^0,
      select: count(r.id),
      preload: [badge: b, attendee: a])
  end

  # # of entries to the final draw
  # global
  defp get_nr_final_entries do
    Repo.all(
      from a in Safira.Accounts.Attendee,
      select: sum(a.entries)
    )
  end

  # tokens atribuidos
  # global in the system + nr os tokes spent
  defp get_nr_tokens_atr(date) do
    total =
      Repo.all(
        from a in Safira.Accounts.Attendee
        select: sum( a.token_balance )
      )
    get_spent_tokens()+total
  end

  # # of tokens spent globaly
  # count nr os roullete rolls * 20
  # count nr sales (by total token ammount)
  defp get_spent_tokens() do
    spent_roulette =
      Repo.all(
        from ap in Safira.Roulette.AttendeePrize,
        select: sum(ap.id) * 20
      )
    spent_store =
      Repo.all(
        from r in Safira.Store.Redeemable
          join: b in assoc(r, :buy)
          select: sum(r.price * b.quantity)
      )
    spent_roulette + spent_store

  end

  # premios ganhos na roleta
  # SHOULD WORK
  # daily task
  defp get_roulette_prizes(date) do
     Repo.all(
      from a in Safira.Accounts.Attendee,
        join: ap in AtendeePrize, on a.id == ap.attendee_id,
        join: p in Prize, on ap.prize_id == p.id,
        where: not (is_nil a.user_id) and fragment("?::date", ap.inserted_at) == ^date,
        select: %{prize: p.name, count(p.id) }
     )
  end

  # premios ganhos na roleta
  # SHOULD WORK
  # global task
  defp get_roulette_prizes_global(date) do
     Repo.all(
      from a in Safira.Accounts.Attendee,
        join: ap in AtendeePrize, on a.id == ap.attendee_id,
        join: p in Prize, on ap.prize_id == p.id,
        where: not (is_nil a.user_id),
        select: %{prize: p.name, count(p.id) }
     )
  end

end
