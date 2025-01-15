defmodule Safira.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :priority, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
