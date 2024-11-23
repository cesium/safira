defmodule Safira.Spotlights.Spotlight do
  use Safira.Schema

  schema "spotlights" do
    field :end, :utc_datetime

    belongs_to :company, Safira.Companies.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, [:end, :company_id])
    |> validate_required([:end, :company_id])
    |> foreign_key_constraint(:company_id)
  end
end
