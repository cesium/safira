defmodule Safira.Repo.Migrations.CreateMinesweeperRounds do
  use Ecto.Migration

  def change do
    create table(:minesweeper_rounds, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :mine_positions, {:array, :integer}
      add :revealed_positions, {:array, :integer}
      add :status, :string, null: false
      add :bet, :integer, null: false
      add :tokens, :integer, default: 0

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:minesweeper_rounds, [:attendee_id])

    create unique_index(:minesweeper_rounds, [:attendee_id],
             where: "status = 'active'",
             name: :active_minesweeper_round_per_attendee
           )
  end
end
