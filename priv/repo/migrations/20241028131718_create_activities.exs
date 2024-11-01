defmodule Safira.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :string
      add :location, :string
      add :date, :date, null: false
      add :time_start, :time, null: false
      add :time_end, :time, null: false
      add :has_enrolments, :boolean, default: false, null: false
      add :category_id, references(:activity_categories, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
