defmodule Safira.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id)
      add :url, :string
      add :image, :string

      timestamps(type: :utc_datetime)
    end

    create index(:team_members, [:team_id])
  end
end
