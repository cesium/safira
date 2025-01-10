defmodule Safira.Contest.BadgeRedeem do
  @moduledoc """
  Event badge redeem.
  """

  use Safira.Schema

  alias Safira.Accounts.{Attendee, Staff}
  alias Safira.Contest.Badge

  @required_fields ~w(badge_id attendee_id)a
  @optional_fields ~w(redeemed_by_id)a

  schema "badge_redeems" do
    belongs_to :badge, Badge

    belongs_to :attendee, Attendee
    belongs_to :redeemed_by, Staff

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(badge_redeem, attrs) do
    badge_redeem
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:badge_id, :attendee_id])
  end
end
