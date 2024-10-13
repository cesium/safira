defmodule Safira.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :url, :string
      add :logo, :string

      add :badge_id, references(:badges, type: :binary_id, on_delete: :delete_all)
      add :tier_id, references(:tiers, type: :binary_id, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
