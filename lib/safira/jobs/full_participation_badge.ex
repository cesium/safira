defmodule Safira.Jobs.FullParticipationBadge do
  @moduledoc """
  Job to gift the full participation badge to all eligible attendees.
  Eligible attendees are those that completed all days of the contest.

  Receives the badge_id.
  """
  import Ecto.Query, warn: false

  alias Safira.Accounts
  alias Safira.Contest

  @spec run(integer()) :: :ok
  def run(badge_id) do
    list = [
      get_badge_by_name("Dia 1"),
      get_badge_by_name("Dia 2"),
      get_badge_by_name("Dia 3"),
      get_badge_by_name("Dia 4")
    ]

    Accounts.list_active_attendees()
    |> Enum.each(&maybe_gift_badge(&1.id, badge_id, list))
  end

  defp maybe_gift_badge(attendee_id, badge_id, list) do
    give? =
      Enum.map(list, &attendee_has_badge?(&1, attendee_id))
      # Checks that all values are true (attendee redeemed all daily badges)
      |> Enum.reduce(fn x, acc -> x && acc end)

    if give? do
      create_redeem(attendee_id, badge_id)
    end
  end

  defp attendee_has_badge?(badge, attendee_id) do
    !is_nil(Contest.get_keys_redeem(attendee_id, badge.id))
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

  defp get_badge_by_name(name) do
    Contest.get_badge_name!(name)
  end
end
