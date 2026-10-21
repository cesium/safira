defmodule Safira.Minigames.ScratchCard do
  @moduledoc """
  Scratch card minigame cards.
  """
  use Safira.Schema

  @required_fields ~w(attendee_id)a
  @optional_fields ~w(drop_id)a

  schema "scratch_cards" do
    belongs_to :attendee, Safira.Accounts.Attendee
    belongs_to :drop, Safira.Minigames.ScratchCardDrop

    many_to_many :symbols, Safira.Minigames.ScratchCardSymbol, join_through: "cards_symbols"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card, attrs) do
    scratch_card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:symbols)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:drop_id)
  end
end
