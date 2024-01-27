defmodule Safira.Repo.Migrations.CreatePayouts do
  use Ecto.Migration

  def change do
    create table(:payouts) do
      add :probability, :float
      add :multiplier, :float

      timestamps()
    end

    create unique_index(:payouts, [:multiplier])
  end
end
