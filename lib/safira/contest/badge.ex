defmodule Safira.Contest.Badge do
  use Ecto.Schema
  import Ecto.Changeset


  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :company_id, :id

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [:begin, :end])
    |> validate_required([:begin, :end])
  end
end
