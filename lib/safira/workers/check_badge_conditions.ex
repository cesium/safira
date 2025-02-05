defmodule Safira.Workers.CheckBadgeConditions do
  use Oban.Worker, queue: :badge_conditions

  alias Safira.Repo
  alias Safira.Contest
  alias Safira.Contest.BadgeCondition
  alias Safira.Accounts.Attendee

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"attendee_id" => attendee_id, "badge_id" => badge_id}}) do
    attendee = Repo.get!(Attendee, attendee_id)
    badge = Repo.get!(Badge, badge_id)

    Contest.list_valid_badge_conditions(badge.category)
    |> Enum.each(fn condition ->
      if meets_condition?(attendee, condition) do
        # Redeem
      end
    end)
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
    Contest.get_attendee_redeemed_badges_count(attendee, category) == Contest.get_category_badges_count(category)
  end
end
