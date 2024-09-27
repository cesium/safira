defmodule Safira.Minigames.Prize do
  use Safira.Schema

  @required_fields ~w(name stock)a
  @optional_fields ~w(image)a

  @derive {
    Flop.Schema,
    filterable: [:name], sortable: [:name, :stock], default_limit: 11
  }

  schema "prizes" do
    field :name, :string
    field :stock, :integer
    field :image, Uploaders.Prize.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(prize, attrs) do
    prize
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_number(:stock, greater_than_or_equal_to: 0)
    |> cast_attachments(attrs, [:image])
    |> validate_required(@required_fields)
  end

  def update_stock_changeset(prize, attrs) do
    prize
    |> cast(attrs, [:stock])
    |> validate_number(:stock, greater_than_or_equal_to: 0)
  end

  def image_changeset(prize, attrs) do
    prize
    |> cast_attachments(attrs, [:image])
  end
end
