defmodule Safira.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :permissions, :map, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])
  end
end
