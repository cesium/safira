defmodule Safira.Repo.Migrations.AttendeeNowName do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :name, :string
    end
  end
end
