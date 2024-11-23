defmodule Safira.Companies.Tier do
  @moduledoc """
  Sponsor tiers for companies.
  """
  use Safira.Schema

  @required_fields ~w(name priority)a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "tiers" do
    field :name, :string
    field :priority, :integer
    field :multiplier, :float, default: 0.0

    has_many :companies, Safira.Companies.Company, foreign_key: :tier_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def changeset_multiplier(tier, attrs) do
    tier
    |> cast(attrs, [:multiplier])
    |> validate_required([:multiplier])
  end
end
