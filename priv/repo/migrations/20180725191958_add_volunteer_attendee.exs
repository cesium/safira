defmodule Safira.Repo.Migrations.AddVolunteerUser do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :volunteer, :boolean, default: false, null: false
    end
  end
end
