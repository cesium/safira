defmodule Safira.Companies.Tier do
  @moduledoc """
  Sponsor tiers for companies.
  """
  use Safira.Schema

  @required_fields ~w(name priority)a
  @optional_fields ~w(full_cv_access)a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "tiers" do
    field :name, :string
    field :priority, :integer
    field :spotlight_multiplier, :float, default: 0.0
    field :max_spotlights, :integer, default: 1
    field :full_cv_access, :boolean, default: false

    has_many :companies, Safira.Companies.Company, foreign_key: :tier_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def changeset_multiplier(tier, attrs) do
    tier
    |> cast(attrs, [:spotlight_multiplier, :max_spotlights])
    |> validate_required([:spotlight_multiplier, :max_spotlights])
  end
end
