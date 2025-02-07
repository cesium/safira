defmodule Safira.Workers.RunBadgeTriggers do
  @moduledoc """
  This worker gets called when an attendee triggers an event that might award them a badge.
  """
  use Oban.Worker, queue: :badge_triggers

  alias Safira.{Accounts, Contest}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"attendee_id" => attendee_id, "event" => event} = _args}) do
    attendee = Accounts.get_attendee!(attendee_id)

    Contest.list_event_badge_triggers(event)
    |> Enum.each(fn badge_trigger ->
      # Check if the attendee doesn't have the badge
      if !Contest.attendee_owns_badge?(attendee_id, badge_trigger.badge_id) do
        # Redeem badge
        Contest.redeem_badge(badge_trigger.badge, attendee)
      end
    end)
  end
end
