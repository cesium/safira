defmodule Mix.Tasks.Gift.Badge.Full.Participation do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  def run(date) do

    Mix.Task.run("app.start")

    Mix.shell().info("badges:")
    Mix.shell().info("roleta:")
    Mix.shell().info("entradas:")
    Mix.shell().info("tokens:")
    Mix.shell().info("premios:")

  end

  # # badges atribuidos
  defp get_nbadges(date) do
    Repo.all(from r in Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and fragment("?::date", r.inserted_at) == ^date and b.type != ^0 and fragment("?::date", t.day) == ^date,
      select: count(r.id)
      preload: [badge: b, attendee: a])
  end


  # # of badges overall
  defp get_badges_global do
    Repo.all(from r in Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where:  not(a.volunteer) and not(is_nil(a.nickname)) and  b.type != ^0,
      select: count(r.id)
      preload: [badge: b, attendee: a])
  end

  # # of tokens spent globaly
  defp get_spent_tokens(date) do
    Repo.all(
      from a in Safira.Accounts.Attendee,
        join: r in Redeem, on: a.id == r.attendee_id,
        join: b in Badge, on: r.badge_id == b.id,
        join: t in DailyToken, on: a.id == t.attendee_id,
        where: not (is_nil a.user_id) and fragment("?::date", r.inserted_at) == ^date and b.type != ^0 and fragment("?::date", t.day) == ^date,
        select: %{attendee: a, token_count: t.quantity},
        preload: [badges: b, daily_tokens: t]
    )
  end


  # entradas para o sorteio final
  defp get_nr_final_entries do
    Repo.all()
  end


  # tokens atribuidos
  defp get_nr_tokens_str(date) do

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
