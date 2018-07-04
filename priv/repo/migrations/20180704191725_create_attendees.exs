defmodule Safira.Repo.Migrations.CreateAttendees do
  use Ecto.Migration

  def change do
    create table(:attendees) do
      add :uuid, :string
      add :nickname, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    alter table(:users) do
      remove :uuid
    end

    create unique_index(:attendees, [:uuid])
    create unique_index(:attendees, [:nickname])
  end
end
