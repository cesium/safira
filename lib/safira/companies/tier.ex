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

    has_many :companies, Safira.Companies.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
