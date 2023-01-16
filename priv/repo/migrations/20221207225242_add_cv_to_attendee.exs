defmodule Safira.Repo.Migrations.AddCVToAttendee do
  use Ecto.Migration

  def change do
    alter table(:attendees) do
      add :cv, :string
    end
  end
end
