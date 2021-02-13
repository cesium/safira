defmodule Safira.Repo.Migrations.CreateAttendeesPrizes do
  use Ecto.Migration

  def change do
    create table(:attendees_prizes) do
      add :quantity, :integer
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :prize_id, references(:prizes, on_delete: :delete_all)

      timestamps()
    end

    create index(:attendees_prizes, [:attendee_id])
    create index(:attendees_prizes, [:prize_id])

    create unique_index(:attendees_prizes, [:attendee_id, :prize_id], name: :unique_attendee_prize)
  end
end
