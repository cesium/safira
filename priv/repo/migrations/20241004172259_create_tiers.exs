defmodule Safira.Repo.Migrations.CreateTiers do
  use Ecto.Migration

  def change do
    create table(:tiers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :priority, :integer, null: false
      add :spotlight_multiplier, :float, null: false
      add :max_spotlights, :integer, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
