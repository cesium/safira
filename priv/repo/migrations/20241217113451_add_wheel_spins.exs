defmodule Safira.Repo.Migrations.AddWheelSpins do
  use Ecto.Migration

  def change do
    create table(:wheel_spins, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      add :drop_id, references(:wheel_drops, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end
  end
end
