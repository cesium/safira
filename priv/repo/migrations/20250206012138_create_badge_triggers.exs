defmodule Safira.Repo.Migrations.CreateBadgeTriggers do
  use Ecto.Migration

  def change do
    create table(:badge_triggers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event, :string, null: false
      add :badge_id, references(:badges, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:badge_triggers, [:badge_id])
    create unique_index(:badge_triggers, [:event, :badge_id])
  end
end
