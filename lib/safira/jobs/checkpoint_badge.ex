defmodule Safira.Jobs.CheckpointBadge do
  @moduledoc """
  Job to gift a badge to all eligible attendees.
  Eligible attendees are those that have at least the required number of badges.
  If a badge_type is provided, only attendees with at least the required number of badges of that type will be eligible.

  Receives the badge_id, badge_count, an optional badge_type and a number of entries to the final draw.
  """
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.Badge
  alias Safira.Contest.Redeem
  alias Safira.Repo

  @spec run(integer(), integer(), integer() | nil, integer()) :: :ok
  def run(badge_id, badge_count, badge_type \\ nil, entries) do
    badge = Repo.get(Badge, badge_id)

    case badge_type do
      nil ->
        list_eligible_attendees(badge_count)
        |> Enum.each(&create_redeem(&1, badge, entries))

      _ ->
        list_eligible_attendees_with_badge_type(badge_count, badge_type)
        |> Enum.each(&create_redeem(&1, badge, entries))
    end
  end

  defp list_eligible_attendees(badge_count) do
    Attendee
    |> join(:inner, [a], r in Redeem, on: a.id == r.attendee_id)
    |> join(:inner, [a, r], b in Badge, on: r.badge_id == b.id)
    |> preload([a, r, b], badges: b)
    |> Repo.all()
    |> Enum.map(fn a -> Map.put(a, :badge_count, length(a.badges)) end)
    |> Enum.filter(fn a -> a.badge_count >= badge_count end)
  end

  defp list_eligible_attendees_with_badge_type(badge_count, badge_type) do
    Attendee
    |> join(:inner, [a], r in Redeem, on: a.id == r.attendee_id)
    |> join(:inner, [a, r], b in Badge, on: r.badge_id == b.id)
    |> where([a, r, b], b.type == ^badge_type)
    |> preload([a, r, b], badges: b)
    |> Repo.all()
    |> Enum.map(fn a -> Map.put(a, :badge_count, length(a.badges)) end)
    |> Enum.filter(fn a -> a.badge_count >= badge_count end)
  end

  defp create_redeem(attendee, badge, entries) do
    redeem_attrs = %{
      attendee_id: attendee.id,
      badge_id: badge.id,
      staff_id: 1
    }

    Multi.new()
    |> Multi.insert(:redeem, Redeem.changeset(%Redeem{}, redeem_attrs, :admin))
    |> Multi.update(
      :attendee,
      Attendee.update_on_redeem_changeset(
        attendee,
        %{
          token_balance: attendee.token_balance + badge.tokens,
          entries: attendee.entries + entries
        }
      )
    )
    |> Repo.transaction()
  end
end
