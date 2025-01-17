defmodule Safira.Teams.TeamMember do
  use Safira.Schema

  @required_fields ~w(name team_id)a
  schema "team_members" do
    field :name, :string
    belongs_to :team, Safira.Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
