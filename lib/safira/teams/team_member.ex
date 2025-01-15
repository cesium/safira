defmodule Safira.Teams.TeamMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_members" do
    field :name, :string
    field :team_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
