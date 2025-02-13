defmodule Mix.Tasks.Tunas do
  @moduledoc false

  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Contest.BadgeRedeem
  alias Safira.Repo

  def run(_args \\ []) do
    Mix.Task.run("app.start")

    tunas = ["Jogralhos", "Augustuna", "Gatuna"]

    attendees_with_one = attendees_with_count(tunas, 1)
    attendees_with_all = attendees_with_count(tunas, 3)

    all_badge = Repo.one(from b in Badge, where: b.name == "Mestre Cultural")
    one_badge = Repo.one(from b in Badge, where: b.name == "SEI vai aos Grupos Culturais")

    one_transactions = attendees_with_one
    |> Enum.map(fn at -> give_badge_on_day_transaction(at, one_badge, ~D[2025-02-12]) end)

    all_transactions = attendees_with_all
    |> Enum.map(fn at -> give_badge_on_day_transaction(at, all_badge, ~D[2025-02-12]) end)

    one_transactions ++ all_transactions
    |> Enum.reduce(fn multi_elem, multi_acc -> Ecto.Multi.append(multi_acc, multi_elem) end)
    |> Ecto.Multi.to_list()
    |> IO.inspect()
  end

  defp attendees_with_count(badges, count) do
    BadgeRedeem
      |> join(:inner, [br], a in Attendee, on: br.attendee_id == a.id)
      |> join(:inner, [br, a], b in Badge, on: br.badge_id == b.id)
      |> where([br, a, b], b.name in ^badges)
      |> group_by([br, a, b], a.id)
      |> having([br, a, b], count(br.id) >= ^count)
      |> select([br, a, b], a)
      |> subquery()
      |> preload(:user)
      |> Repo.all()

  end

  defp give_badge_on_day_transaction(attendee, badge, date) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:daily_tokens, DailyTokens |> where([dt], dt.attendee_id == ^attendee.id and dt.day == ^date))
    |> Ecto.Multi.update(:new_daily_tokens, fn %{daily_tokens: daily_tokens} ->
      DailyTokens.changeset(daily_tokens, %{tokens: daily_tokens.tokens + badge.tokens})
    end)
    |> Ecto.Multi.one(:attendee, Attendee |> where([at], at.id == ^attendee.id))
    |> Ecto.Multi.update(:new_attendee, fn %{attendee: attendee} ->
      Attendee.changeset(attendee, %{tokens: attendee.tokens + badge.tokens, entries: attendee.entries + badge.entries})
    end)
    |> Ecto.Multi.insert(:redeem, BadgeRedeem.changeset(%BadgeRedeem{}, %{badge_id: badge.id, attendee_id: attendee.id, redeemed_by_id: nil}))
  end
end

Mix.Tasks.Tunas.run()
