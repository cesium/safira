defmodule Safira.Repo.Migrations.AddEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrolments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      add :activity_id, references(:activities, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:enrolments, [:activity_id])
    create index(:enrolments, [:attendee_id])
    create unique_index(:enrolments, [:activity_id, :attendee_id])

    alter table(:activities) do
      add :enrolment_count, :integer, null: false, default: 0
    end

    create constraint(:activities, :activity_not_overbooked,
             check: "enrolment_count <= max_enrolments"
           )
  end
end
