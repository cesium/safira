defmodule Safira.Minigames.CoinFlipRoom do
  use Safira.Schema

  @required_fields ~w(bet player1_id)a
  @optional_fields ~w(player2_id finished)a

  schema "coin_flip_rooms" do
    belongs_to :player1, Safira.Accounts.Attendee
    belongs_to :player2, Safira.Accounts.Attendee
    field :bet, :integer
    field :finished, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(coin_flip_room, attrs) do
    coin_flip_room
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> foreign_key_constraint(:player1_id)
    |> foreign_key_constraint(:player2_id)
    |> validate_required(@required_fields)
  end
end
