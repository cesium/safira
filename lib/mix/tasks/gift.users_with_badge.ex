defmodule Mix.Tasks.Gift.User.Badge do
  @moduledoc """
  Task to generate a user with a badge
  """
  use Mix.Task

  import Ecto.Query, warn: false
  alias Safira.Contest.Redeem
  alias Safira.Accounts.Company
  alias Safira.Contest.Badge
  alias Safira.Accounts.Attendee
  alias Safira.Repo

  def run(args) do
    Mix.Task.run("app.start")
    create(args)
  end

  def create(badge_id) do
    # give a badge to a list of users which have all company gold badges and exclusive badges

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

    # TODO: Transaction
    attendees
    |> Enum.each(fn id ->
      Repo.insert(%Redeem{attendee_id: id, badge_id: badge_id, manager_id: 1})
    end)
  end
end
