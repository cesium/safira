defmodule Safira.Minigames.SlotsPaytable do
  @moduledoc """
  Schema for slots paytable that defines multipliers and their probabilities.
  Used to determine winning combinations and their payouts in the slots game.
  """
  use Safira.Schema

  @required_fields ~w(multiplier probability)a

  schema "slots_paytables" do
    field :multiplier, :integer
    field :probability, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slots_paytable, attrs) do
    slots_paytable
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:multiplier, greater_than: 0)
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> unique_constraint(:multiplier)
  end
end
