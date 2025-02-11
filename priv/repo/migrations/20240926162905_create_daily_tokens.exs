defmodule Safira.Repo.Migrations.CreateDailyTokens do
  use Ecto.Migration

  def change do
    create table(:daily_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date, null: false
      add :tokens, :integer

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:daily_tokens, [:date, :attendee_id])
  end
end
