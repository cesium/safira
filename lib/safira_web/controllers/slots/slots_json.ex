defmodule SafiraWeb.SlotsJSON do
  @moduledoc false

  def spin_result(data) do
    payout = Map.get(data, :payout)
    tokens = Map.get(data, :tokens)

    %{
      multiplier: payout.multiplier,
      tokens: tokens
    }
  end
end
