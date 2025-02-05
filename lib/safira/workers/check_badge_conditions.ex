defmodule Safira.Workers.CheckBadgeConditions do
  @moduledoc """
  This worker checks if an attendee meets the conditions to redeem a badge.
  """
  use Oban.Worker, queue: :badge_conditions

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Contest.BadgeCondition

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"attendee_id" => attendee_id, "badge_id" => badge_id} = _args}) do
    attendee = Accounts.get_attendee!(attendee_id)
    badge = Contest.get_badge!(badge_id)

    Contest.list_valid_badge_conditions(badge.category)
    |> Enum.each(fn condition ->
      # Check if the attendee doesn't have the badge and meets the condition
      if !Contest.attendee_owns_badge?(attendee_id, condition.badge_id) and
           meets_condition?(attendee, condition) do
        # Redeem badge
        Contest.redeem_badge(condition.badge, attendee)
      end
    end)

    :ok
  end

  defp meets_condition?(attendee, %BadgeCondition{amount_needed: amount, category: category}) do
    case amount do
      nil ->
        has_all_badges_of_category?(attendee, category)

      amount ->
        has_at_least_n_badges_of_category?(attendee, category, amount)
    end
  end

  defp has_at_least_n_badges_of_category?(attendee, category, amount) do
    Contest.get_attendee_redeemed_badges_count(attendee, category) >= amount
  end

  defp has_all_badges_of_category?(attendee, category) do
    Contest.get_attendee_redeemed_badges_count(attendee, category) ==
      Contest.get_category_badges_count(category)
  end
end
