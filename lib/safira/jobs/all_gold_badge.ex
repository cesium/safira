defmodule Safira.Jobs.AllGoldBadge do
  @moduledoc """
  Job to gift the all gold badge to all eligible attendees.
  Eligible attendees are those that visited all gold and exclusive sponsors.

  Receives the badge_id.
  """
  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Repo

  @spec run(integer()) :: :ok
  def run(badge_id) do
    attendees = list_eligible_attendees()
    Enum.each(attendees, &create_redeem(&1.id, badge_id))
  end

  defp list_eligible_attendees do
    companies_count =
      Badge
      |> where([b], b.type == 4)
      |> join(:inner, [b], c in Company, on: c.badge_id == b.id)
      |> where([b, c], c.sponsorship in ["Gold", "Exclusive"])
      |> Repo.aggregate(:count)

    Badge
    |> where([b], b.type == ^4)
    |> join(:inner, [b], c in Company, on: c.badge_id == b.id)
    |> where([b, c], c.sponsorship in ["Gold", "Exclusive"])
    |> join(:inner, [b, c], r in Redeem, on: b.id == r.badge_id)
    |> join(:inner, [b, c, r], a in Attendee, on: a.id == r.attendee_id)
    |> group_by([b, c, r, a], a.id)
    |> having([b, c, r], count(r.id) == ^companies_count)
    |> select([b, c, r, a], a.id)
    |> Repo.all()
  end

  defp create_redeem(attendee_id, badge_id) do
    Contest.create_redeem(
      %{
        attendee_id: attendee_id,
        staff_id: 1,
        badge_id: badge_id
      },
      :admin
    )
  end
end
