defmodule Safira.Spotlights.Spotlight do
  use Safira.Schema

  @required_fields ~w(end company_id)a

  schema "spotlights" do
    field :end, :utc_datetime

    belongs_to :company, Safira.Companies.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:company_id)
  end
end
