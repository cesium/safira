defmodule Safira.RouletteFactory do
  @moduledoc """
  A factory to build all roulette related structs
  """
  defmacro __using__(_opts) do
    quote do
      def attendee_prize_factory do
        quantity = Enum.random(1..10)
        redeemed = Enum.random(0..quantity)

        %Safira.Roulette.AttendeePrize{
          attendee: build(:attendee),
          prize: build(:prize),
          quantity: quantity,
          redeemed: redeemed
        }
      end

      def prize_factory do
        %Safira.Roulette.Prize{
          max_amount_per_attendee: 10,
          name: Faker.Commerce.product_name(),
          probability: 0.5,
          stock: 40,
          is_redeemable: Enum.random([true, false])
        }
      end
    end
  end
end
