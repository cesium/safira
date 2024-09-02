defmodule Safira.Contest.BadgeCondition do
  use Safira.Schema

  @required_fields ~w(badge_id)a
  @optional_fields ~w(logic category_id)a

  schema "badge_conditions" do
    field :logic, :string

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
    |> validate_required(@required_fields)
  end
end
