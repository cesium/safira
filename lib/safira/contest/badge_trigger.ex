defmodule Safira.Contest.BadgeTrigger do
  @moduledoc """
  Attendee actions trigger badge redeems.
  """
  use Safira.Schema
  alias Safira.Contest.Badge

  @required_fields ~w(event badge_id)a
  @events ~w(upload_cv_event play_slots_event play_coin_flip_event play_wheel_event redeem_spotlighted_badge_event link_credential_event)a

  schema "badge_triggers" do
    field :event, Ecto.Enum, values: @events
    belongs_to :badge, Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(badge_trigger, attrs) do
    badge_trigger
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:event, :badge_id],
      message: "badge already has this event trigger",
      error_key: :event
    )
  end

  def events do
    @events
  end
end
