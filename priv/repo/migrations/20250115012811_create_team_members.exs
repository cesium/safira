defmodule Safira.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :name, :string
      add :team_id, :binary_id, primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:team_members, [:team_id])
  end
end
