defmodule Safira.Contest.Badge do
  use Safira.Schema

  @required_fields ~w(name description begin end tokens category_id)a
  @optional_fields ~w(image counts_for_day)a

  @derive {
    Flop.Schema,
    filterable: [:name], sortable: [:name], default_limit: 30
  }

  schema "badges" do
    field :name, :string
    field :description, :string
    field :image, Uploaders.Badge.Type
    field :tokens, :integer
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :counts_for_day, :boolean, default: true

    belongs_to :category, Safira.Contest.BadgeCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> cast_assoc(:category)
    |> validate_required(@required_fields)
  end

  def image_changeset(badge, attrs) do
    badge
    |> cast_attachments(attrs, [:image])
  end
end
