defmodule Safira.Repo.Migrations.CreateSlotsPaytables do
  use Ecto.Migration

  def change do
    create table(:slots_paytables, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :multiplier, :integer
      add :probability, :float

      timestamps(type: :utc_datetime)
    end

    create unique_index(:slots_paytables, [:multiplier])
  end
end
