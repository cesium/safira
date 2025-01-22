defmodule Safira.Teams.Team do
  @moduledoc """
  Team schema.
  """
  use Safira.Schema

  @required_fields ~w(name)a

  schema "teams" do
    field :name, :string
    field :priority, :integer
    has_many :team_members, Safira.Teams.TeamMember

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:name)
  end
end
