defmodule Safira.Contest.BadgeCategory do
  use Safira.Schema

  @required_fields ~w(name color hidden)a
  @colors ~w(gray red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose)a

  schema "badge_categories" do
    field :name, :string
    field :color, Ecto.Enum, values: @colors
    field :hidden, :boolean, default: false

    has_many :badges, Safira.Contest.Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  @doc false
  def colors do
    @colors
  end
end
