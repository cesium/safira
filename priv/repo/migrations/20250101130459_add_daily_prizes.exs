defmodule Safira.Repo.Migrations.AddDailyPrizes do
  use Ecto.Migration

  def change do
    create table(:daily_prizes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :prize_id, references(:prizes, type: :binary_id, on_delete: :delete_all), null: false
      add :date, :date, null: false
      add :place, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:daily_prizes, [:date, :place])
  end
end
