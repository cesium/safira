defmodule Safira.ContestFactory do
  defmacro __using__(_opts) do
    quote do
      def badge_factory do
        %Safira.Contest.Badge{
          name: Faker.Pokemon.En.name(),
          description: Faker.StarWars.En.quote(),
          type: Enum.random(0..9),
          begin_badge: Faker.DateTime.backward(2),
          end_badge: Faker.DateTime.forward(2),
          tokens: Enum.random(100..255)
        }
      end

      def redeem_factory do
        %Safira.Contest.Redeem{
          attendee: build(:attendee),
          badge: build(:badge),
          manager: build(:manager)
        }
      end
    end
  end
end
