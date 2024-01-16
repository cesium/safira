defmodule Safira.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string, null: false

      timestamps()
    end

    alter table(:attendees) do
      add :course_id, references(:courses, on_delete: :nothing)
    end
  end
end
