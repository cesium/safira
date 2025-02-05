defmodule Safira.Repo.Migrations.CreateSlotsReelIcons do
  use Ecto.Migration

  def change do
    create table(:slots_reel_icons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :string
      add :reel_0_index, :integer
      add :reel_1_index, :integer
      add :reel_2_index, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
