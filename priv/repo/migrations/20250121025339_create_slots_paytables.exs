defmodule Safira.Repo.Migrations.CreateSlotsPaytables do
  use Ecto.Migration

  def change do
    create table(:slots_paytables) do
      add :multiplier, :integer
      add :position_figure_0, :integer
      add :position_figure_1, :integer
      add :position_figure_2, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
