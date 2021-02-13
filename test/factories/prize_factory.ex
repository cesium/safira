defmodule Safira.PrizeFactory do
  defmacro __using__(_opts) do
    quote do
      def prize_factory do
        %Safira.Roulette.Prize{
          max_amount_per_attendee: 10,
          name: "Prize test name",
          probability: 0.5,
          stock: 40
        }
      end
    end
  end
end
