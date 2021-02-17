defmodule Safira.Repo.Migrations.AddAttendeeEntries do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :entries, :integer, default: 0
    end
  end
end
