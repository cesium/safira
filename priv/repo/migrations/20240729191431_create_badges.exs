defmodule Safira.Repo.Migrations.CreateBadges do
  use Ecto.Migration

  def change do
    create table(:badges, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :image, :string
      add :begin, :utc_datetime
      add :end, :utc_datetime
      add :tokens, :integer
      add :counts_for_day, :boolean
      add :category_id, references(:badge_categories, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
