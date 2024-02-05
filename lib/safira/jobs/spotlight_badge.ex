defmodule Safira.Jobs.SpotlightBadge do
  @moduledoc """
  Job to gift the Spotlight badge to all eligible attendees.
  Eligible attendees are those that have redeemed a spotlighted badge.

  Receives the badge_id to gift.
  """
  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Repo

  @spec run(integer()) :: :ok
  def run(badge_id) do
    badge = Repo.get(Badge, badge_id)

    list_eligible_attendees(badge_id)
    |> Enum.each(&create_redeem(&1, badge))
  end

  defp list_eligible_attendees(badge_id) do
    Attendee
    |> join(:inner, [a], r in assoc(a, :redeems))
    |> where([a, r], r.spotlighted == true and r.badge_id != ^badge_id)
    |> Repo.all()
  end

  defp create_redeem(attendee, badge) do
    Contest.create_redeem(
      %{
        attendee_id: attendee.id,
        staff_id: 1,
        badge_id: badge.id
      },
      :admin
    )
  end
end
