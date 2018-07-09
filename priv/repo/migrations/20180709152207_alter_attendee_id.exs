defmodule Safira.Repo.Migrations.AlterAttendeeId do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      remove :uuid
      remove :id
      add :id, :uuid, primary_key: true
    end
  end
end
