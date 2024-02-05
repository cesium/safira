defmodule Safira.Repo.Migrations.CreateSpotlights do
  use Ecto.Migration

  def change do
    create table(:spotlights) do
      add :active, :boolean, default: false, null: false
      add :badge_id, references(:badges, on_delete: :nothing)

      add :lock_version, :integer, default: 1

      timestamps()
    end

    create index(:spotlights, [:badge_id])
  end
end
