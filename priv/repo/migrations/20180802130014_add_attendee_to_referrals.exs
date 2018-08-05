defmodule Safira.Repo.Migrations.AddAttendeeToReferrals do
  use Ecto.Migration

  def change do
    alter table(:referrals) do
      add :attendee_id, references(:attendees, on_delete: :delete_all, type: :uuid)
    end
  end
end
