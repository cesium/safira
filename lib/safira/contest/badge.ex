defmodule Safira.Contest.Badge do
  @moduledoc """
  Event badge.
  """
  use Safira.Schema

  alias Safira.Companies

  @required_fields ~w(name description begin end tokens entries category_id)a
  @optional_fields ~w(image counts_for_day givable is_checkpoint)a

  @derive {
    Flop.Schema,
    filterable: [:name], sortable: [:name], default_limit: 30
  }

  schema "badges" do
    field :name, :string
    field :description, :string
    field :image, Uploaders.Badge.Type
    field :tokens, :integer
    field :entries, :integer
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :counts_for_day, :boolean, default: true
    field :givable, :boolean, default: true
    field :is_checkpoint, :boolean, default: false

    belongs_to :category, Safira.Contest.BadgeCategory
    has_one :company, Companies.Company

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
