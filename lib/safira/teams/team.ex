defmodule Safira.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :priority, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :priority])
    |> validate_required([:name, :priority])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:priority, greater_than: 0) 
  end
end
