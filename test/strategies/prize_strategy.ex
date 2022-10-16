defmodule Safira.PrizeStrategy do
  @moduledoc """
  ExMachina strategy for creating prizes
  """
  use ExMachina.Strategy, function_name: :create_prize_strategy

  def handle_create_prize_strategy(record, _opts) do
    {:ok, prize} =
      Safira.Roulette.create_prize(%{
        max_amount_per_attendee: record.max_amount_per_attendee,
        name: record.name,
        probability: record.probability,
        stock: record.stock,
        is_redeemable: record.is_redeemable
      })

    prize
  end
end
