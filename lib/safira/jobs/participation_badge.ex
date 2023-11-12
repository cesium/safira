defmodule Safira.Jobs.ParticipationBadge do
  @moduledoc """
  Job to gift the participation badge to all eligible attendees.
  Eligible attendees are those that completed at least a given number of days of the contest.

  Receives the badge_id and the number of days of participation.
  """
  import Ecto.Query, warn: false

  alias Safira.Accounts
  alias Safira.Contest

  @spec run(integer(), integer()) :: :ok
  def run(badge_id, days) do
    attendees = Accounts.list_active_attendees()

    list = [
      get_badge_by_name("Dia 1"),
      get_badge_by_name("Dia 2"),
      get_badge_by_name("Dia 3"),
      get_badge_by_name("Dia 4")
    ]

    Enum.each(attendees, &maybe_gift_badge(&1.id, badge_id, list, days))
  end

  defp maybe_gift_badge(attendee_id, badge_id, list, days) do
    give? =
      Enum.map(list, &attendee_has_badge?(&1, attendee_id))
      # Filters for true values (badges redeemed by the attendee)
      # and then checks if their count is greater than or equal to the number of days
      |> Enum.filter(fn x -> x end)
      |> Enum.count()
      |> then(fn x -> x >= days end)

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
