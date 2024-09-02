defmodule Safira.Repo.Migrations.CreateBadgeConditions do
  use Ecto.Migration

  def change do
    create table(:badge_conditions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :logic, :string

      add :category_id, references(:badge_categories, type: :binary_id, on_delete: :delete_all)
      add :badge_id, references(:badges, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
