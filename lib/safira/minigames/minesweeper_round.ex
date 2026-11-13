defmodule Safira.Minigames.MinesweeperRound do
  @moduledoc """
  Minesweeper minigame games.
  """
  use Safira.Schema

  @required_fields ~w(attendee_id mine_positions revealed_positions status bet tokens)a
  @minesweeper_status ~w(active lost cashed_out)a

  schema "minesweeper_rounds" do
    field :mine_positions, {:array, :integer}
    field :revealed_positions, {:array, :integer}, default: []
    field :status, Ecto.Enum, values: @minesweeper_status, default: :active
    field :bet, :integer
    field :tokens, :integer, default: 0

    belongs_to :attendee, Safira.Accounts.Attendee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(minesweeper_round, attrs) do
    minesweeper_round
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> validate_number(:bet, greater_than: 0)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> unique_constraint(:attendee_id,
      name: :active_minesweeper_round_per_attendee,
      message: "attendee already has an active game"
    )
  end
end
