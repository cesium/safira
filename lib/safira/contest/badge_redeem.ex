defmodule Safira.Contest.BadgeRedeem do
  @moduledoc """
  A redeem happens when a staff / company gives a badge to an attendee
  """
  use Safira.Schema

  alias Safira.Accounts.{Attendee, Staff}
  alias Safira.Contest.Badge

  @required_fields ~w(badge_id attendee_id)a
  @optional_fields ~w(redeemed_by_id)a

  @derive {Flop.Schema,
           filterable: [:badge_id, :attendee_id, :redeemed_by_id, :name],
           sortable: [:inserted_at, :updated_at],
           default_limit: 10,
           max_limit: 50,
           join_fields: [
             name: [
               binding: :badge,
               field: :name
             ]
           ]}

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
    |> unique_constraint([:attendee_id, :badge_id],
      message: "attendee already has this badge",
      error_key: :redeem
    )
  end
end
