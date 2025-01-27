defmodule Safira.Repo.Migrations.CreateCoinFlipRooms do
  use Ecto.Migration

  def change do
    create table(:coin_flip_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player1_id, references(:attendees, type: :binary_id, on_delete: :delete_all)
      add :player2_id, references(:attendees, type: :binary_id, on_delete: :delete_all)
      add :bet, :integer
      add :finished, :boolean, default: false
      add :result, :string

      timestamps(type: :utc_datetime)
    end
  end
end
