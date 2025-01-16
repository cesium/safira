defmodule Safira.Teams.TeamMember do
  use Safira.Schema

  schema "team_members" do
    field :name, :string
    field :team_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:name, :team_id])
    |> validate_required([:name, :team_id])
    |> unique_constraint(:name)
  end
end
