defmodule Safira.Repo.Migrations.CreateActivityCategories do
  use Ecto.Migration

  def change do
    create table(:activity_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:activity_categories, [:name])
  end
end
