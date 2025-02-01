defmodule Safira.Minigames.SlotsPayline do
  @moduledoc """
  Schema for slots payline that defines the positions of the slots.
  Used to determine winning combinations and their payouts in the slots game.
  """
  use Safira.Schema

  @required_fields ~w(paytable_id)a
  @optional_fields ~w(position_0 position_1 position_2)a

  schema "slots_paylines" do
    field :position_0, :integer
    field :position_1, :integer
    field :position_2, :integer
    belongs_to :paytable, Safira.Minigames.SlotsPaytable

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slots_payline, attrs) do
    slots_payline
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> foreign_key_constraint(:paytable_id)
    |> validate_required(@required_fields)
  end
end
