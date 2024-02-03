defmodule Safira.SlotsFactory do
  @moduledoc """
  A factory to build all slots related structs
  """
  defmacro __using__(_opts) do
    quote do
      def attendee_payout_factory do
        payout = build(:payout)
        bet = Enum.random(1..100)
        tokens = (payout.multiplier * bet) |> round()

        %Safira.Slots.AttendeePayout{
          attendee: build(:attendee),
          payout: payout,
          bet: bet,
          tokens: tokens
        }
      end

      def payout_factory do
        %Safira.Slots.Payout{
          probability: 0.5,
          multiplier: Enum.random(1..10) / 1
        }
      end
    end
  end
end
