defmodule Safira.Minigames.WheelDrop do
  @moduledoc """
  Lucky wheel minigame drop.
  """
  use Safira.Schema

  @required_fields ~w(probability max_per_attendee)a
  @optional_fields ~w(prize_id badge_id tokens entries)a

  schema "wheel_drops" do
    field :probability, :float
    field :max_per_attendee, :integer
    field :tokens, :integer, default: 0
    field :entries, :integer, default: 0

    belongs_to :prize, Safira.Minigames.Prize
    belongs_to :badge, Safira.Contest.Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wheel_drop, attrs) do
    wheel_drop
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:max_per_attendee, greater_than_or_equal_to: 0)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> validate_number(:entries, greater_than_or_equal_to: 0)
    |> validate_required(@required_fields)
  end
end
