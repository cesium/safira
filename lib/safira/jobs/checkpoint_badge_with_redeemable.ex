defmodule Safira.Jobs.CheckpointBadgeWithRedeemable do
  @moduledoc """
  Job to gift a badge and a redeemable to all eligible attendees.
  Eligible attendees are those that have at least the required number of badges from a specific type.

  Receives the badge_id, badge_count, badge_type, number of entries to the final draw and a redeemable_id.
  """
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.Badge
  alias Safira.Contest.Redeem
  alias Safira.Repo
  alias Safira.Store

  @spec run(integer(), integer(), integer(), integer(), integer()) :: :ok
  def run(badge_id, badge_count, badge_type, entries, redeemable_id) do
    attendees = list_eligible_attendees(badge_count, badge_type)
    badge = Repo.get(Badge, badge_id)

    Enum.each(attendees, &create_redeem(&1, badge, entries))
    Enum.each(attendees, &gift_redeemable(&1, redeemable_id))
  end

  defp list_eligible_attendees(badge_count, badge_type) do
    Attendee
    |> join(:inner, [a], r in Redeem, on: a.id == r.attendee_id)
    |> join(:inner, [a, r], b in Badge, on: r.badge_id == b.id)
    |> where([a, r, b], b.badge_type == ^badge_type)
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
  end

  defp gift_redeemable(attendee, redeemable_id) do
    Store.buy_redeemable(redeemable_id, attendee)
  end
end
