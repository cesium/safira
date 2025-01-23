defmodule Safira.Contest.BadgeCondition do
  @moduledoc """
  Condition for badge automatic redeem.
  """
  use Safira.Schema

  @required_fields ~w(badge_id)a
  @optional_fields ~w(amount_needed category_id begin end)a

  schema "badge_conditions" do
    field :amount_needed, :integer
    field :begin, :utc_datetime
    field :end, :utc_datetime

    belongs_to :category, Safira.Contest.BadgeCategory
    belongs_to :badge, Safira.Contest.Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(condition, attrs) do
    condition
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:category)
    |> cast_assoc(:badge)
    |> validate_number(:amount_needed, greater_than: 0)
    |> validate_badge_condition_timestamps()
    |> validate_required(@required_fields)
  end

  def validate_badge_condition_timestamps(condition) do
    start_timestamp = get_field(condition, :begin)
    end_timestamp = get_field(condition, :end)

    if start_timestamp != nil and end_timestamp != nil do
      if Date.compare(start_timestamp, end_timestamp) in [:gt] do
        condition
        |> Ecto.Changeset.add_error(
          :end,
          "must be after the start timestamp"
        )
      else
        condition
      end
    else
      condition
    end
  end
end
