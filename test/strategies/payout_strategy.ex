defmodule Safira.PayoutStrategy do
  @moduledoc """
  ExMachina strategy for creating payouts
  """
  use ExMachina.Strategy, function_name: :create_payout_strategy

  def handle_create_payout_strategy(record, _opts) do
    {:ok, payout} =
      Safira.Slots.create_payout(%{
        probability: record.probability,
        multiplier: record.multiplier
      })

    payout
  end
end
