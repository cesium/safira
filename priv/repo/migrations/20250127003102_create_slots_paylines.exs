defmodule Safira.Repo.Migrations.CreateSlotsPaylines do
  use Ecto.Migration

  def change do
    create table(:slots_paylines, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :position_0, :integer
      add :position_1, :integer
      add :position_2, :integer
      add :multiplier_id, references(:slots_paytables, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
