defmodule Safira.Jobs.DailyBadge do
  @moduledoc """
  Job to gift the daily badge to all eligible attendees.
  Eligible attendees are those that have at least one redeem on the given date.

  Receives the badge_id and the date of the day, in yyyy-mm-dd format.
  """
  import Ecto.Query, warn: false

  require Logger

  alias Safira.Repo
  alias Safira.Accounts.Attendee
  alias Safira.Contest

  @spec run(integer(), String.t()) :: :ok
  def run(badge_id, date) do
    validate_date_format(date)

    attendees = list_eligible_attendees(date)
    Enum.each(attendees, &create_redeem(&1.id, badge_id))
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

  defp validate_date_format(date) do
    case Date.from_iso8601(date) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        Logger.error("Invalid date format. Please provide a date in yyyy-mm-dd format.")
    end
  end
end
