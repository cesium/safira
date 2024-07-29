defmodule Safira.Repo.Migrations.CreateBadgeCategories do
  use Ecto.Migration

  def change do
    create table(:badge_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color, :string
      add :hidden, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:badge_categories, [:name])
  end
end
