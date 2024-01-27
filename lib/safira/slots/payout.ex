defmodule Safira.Slots.Payout do
  @moduledoc """
  Payouts listed in the pay table that can be won by playing slots.
  """
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "payouts" do
    field :probability, :float
    # supports float multipliers like 1.5x
    field :multiplier, :float

    timestamps()
  end

  def changeset(payout, attrs) do
    payout
    |> cast(attrs, [:probability, :multiplier])
    |> validate_required([:probability, :multiplier])
  end
end
