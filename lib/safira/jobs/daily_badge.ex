defmodule Safira.Jobs.DailyBadge do
  @moduledoc """
  Job to gift the daily badge to all eligible attendees.
  Eligible attendees are those that have at least one redeem on the given date.

  Receives the badge_id and the date of the day, in yyyy-mm-dd format.
  """
  import Ecto.Query, warn: false

  require Logger

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.{Badge, Redeem}
  alias Safira.Repo

  @spec run(integer(), String.t()) :: :ok | no_return()
  def run(badge_id, date) do
    date = date |> Date.from_iso8601!()

    list_eligible_attendees(date)
    |> Enum.each(&create_redeem(&1.id, badge_id))
  end

  defp list_eligible_attendees(date) do
    Attendee
    |> join(:inner, [a], r in Redeem, on: a.id == r.attendee_id)
    |> join(:inner, [a, r], b in Badge, on: r.badge_id == b.id)
    |> where([a, r, b], not is_nil(a.user_id) and fragment("?::date", r.inserted_at) == ^date)
    |> preload([a, r, b], badges: b)
    |> Repo.all()
    |> Enum.map(&Map.put(&1, :badge_count, length(&1.badges)))
    |> Enum.filter(&(&1.badge_count > 0))
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
