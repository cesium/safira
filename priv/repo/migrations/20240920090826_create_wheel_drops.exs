defmodule Safira.Repo.Migrations.CreateWheelDrops do
  use Ecto.Migration

  def change do
    create table(:wheel_drops, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :probability, :float
      add :max_per_attendee, :integer
      add :tokens, :integer, default: 0
      add :entries, :integer, default: 0

      add :prize_id, references(:prizes, type: :binary_id, on_delete: :delete_all)
      add :badge_id, references(:badges, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
