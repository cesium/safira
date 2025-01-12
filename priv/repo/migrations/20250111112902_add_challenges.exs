defmodule Safira.Repo.Migrations.AddChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :description, :text, null: false
      add :type, :string, null: false
      add :display_priority, :integer, null: false, default: 0

      add :date, :date, null: true

      timestamps(type: :utc_datetime)
    end

    create table(:challenges_prizes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :prize_id, references(:prizes, type: :binary_id, on_delete: :delete_all), null: false

      add :challenge_id, references(:challenges, type: :binary_id, on_delete: :delete_all),
        null: false

      add :place, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:challenges_prizes, [:challenge_id])
    create unique_index(:challenges_prizes, [:challenge_id, :place])
  end
end
