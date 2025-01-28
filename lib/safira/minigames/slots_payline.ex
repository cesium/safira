defmodule Safira.Minigames.SlotsPayline do
  @moduledoc """
  Schema for slots payline that defines the positions of the slots.
  Used to determine winning combinations and their payouts in the slots game.
  """
  use Safira.Schema

  schema "slots_paylines" do
    field :position_1, :integer
    field :position_0, :integer
    field :position_2, :integer
    belongs_to :multiplier, Safira.Minigames.SlotsPaytable

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slots_payline, attrs) do
    slots_payline
    |> cast(attrs, [:position_0, :position_1, :position_2])
    |> foreign_key_constraint(:multiplier_id)
    |> validate_required([:position_0, :position_1, :position_2])
  end
end
