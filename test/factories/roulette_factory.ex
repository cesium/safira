defmodule Safira.RouletteFactory do
  defmacro __using__(_opts) do
    quote do
      def prize_factory do
        %Safira.Roulette.Prize{
          max_amount_per_attendee: Enum.random(1..10),
          name: Faker.Commerce.product_name(),
          probability: 0.5,
          stock: Enum.random(1..40)
        }
      end
    end
  end
end
