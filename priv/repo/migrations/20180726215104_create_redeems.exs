defmodule Safira.Repo.Migrations.CreateRedeems do
  use Ecto.Migration

  def change do
    create table(:redeems) do
      add :badge_id, references(:badges, on_delete: :delete_all)
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
      add :staff_id, references(:staffs, on_delete: :nothing)

      timestamps()
    end

    create index(:redeems, [:badge_id])
    create index(:redeems, [:attendee_id])
    create unique_index(:redeems, [:attendee_id, :badge_id], name: :unique_attendee_badge)
  end
end
