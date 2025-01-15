defmodule Safira.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :name, :string
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:team_members, [:team_id])
  end
end
