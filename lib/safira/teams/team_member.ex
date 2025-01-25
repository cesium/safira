defmodule Safira.Teams.TeamMember do
  @moduledoc """
  Team member schema.
  """
  use Safira.Schema

  @required_fields ~w(name team_id)a
  @optional_fields ~w(url)a
  schema "team_members" do
    field :name, :string
    belongs_to :team, Safira.Teams.Team
    field :url, :string
    field :image, Uploaders.Member.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
    |> validate_url(:url)
  end

  @doc false
  def image_changeset(team_member, attrs) do
    team_member
    |> cast_attachments(attrs, [:image])
  end
end
