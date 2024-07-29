defmodule Safira.Repo.Migrations.CreateAttendees do
  use Ecto.Migration

  def change do
    create table(:attendees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tokens, :integer, default: 0
      add :entries, :integer, default: 0
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:attendees, [:user_id])
  end
end
