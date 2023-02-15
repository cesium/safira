defmodule Mix.Tasks.Gift.AllGold.Badge do
  @moduledoc """
  Task to give a badge to a list of users which have all company gold badges and exclusive badges
  """
  use Mix.Task

  import Ecto.Query, warn: false

  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Accounts.Company
  alias Safira.Contest.Badge
  alias Safira.Accounts.Attendee
  alias Safira.Repo

  def run(args) when length(args) == 1 do
    Mix.Task.run("app.start")

    args |> List.first() |> String.to_integer() |> create()
  end

  def run(_args) do
    Mix.shell().error("You must provide a badge_id")
  end

  def create(badge_id) do
    companies =
      Badge
      |> where([b], b.type == 4)
      |> join(:inner, [b], c in Company, on: c.badge_id == b.id)
      |> where([b, c], c.sponsorship in ["Gold", "Exclusive"])
      |> Repo.aggregate(:count)

    attendees =
      Badge
      |> where([b], b.type == ^4)
      |> join(:inner, [b], c in Company, on: c.badge_id == b.id)
      |> where([b, c], c.sponsorship in ["Gold", "Exclusive"])
      |> join(:inner, [b, c], r in Redeem, on: b.id == r.badge_id)
      |> join(:inner, [b, c, r], a in Attendee, on: a.id == r.attendee_id)
      |> group_by([b, c, r, a], a.id)
      |> having([b, c, r], count(r.id) == ^companies)
      |> select([b, c, r, a], a.id)
      |> Repo.all()

    # TODO: Multi transaction
    attendees
    |> Enum.each(fn id ->
      Contest.create_redeem(%{attendee_id: id, badge_id: badge_id, manager_id: 1})
    end)
  end
end
