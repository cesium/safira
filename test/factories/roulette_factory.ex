defmodule Safira.RouletteFactory do
  defmacro __using__(_opts) do
    quote do
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
