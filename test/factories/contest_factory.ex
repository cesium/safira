defmodule Safira.ContestFactory do
  defmacro __using__(_opts) do
    quote do
      def badge_factory do
        %Safira.Contest.Badge{
          name: Faker.Pokemon.En.name(),
          description: Faker.StarWars.En.quote(),
          type: Enum.random(1..9),
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

      def referral_factory do
        %Safira.Contest.Referral{
          available: true,
          badge: build(:badge)
        }
      end

      def daily_token_factory do
        %Safira.Contest.DailyToken{
          attendee: build(:attendee),
          day: DateTime.utc_now(),
          quantity: 10
        }
      end
    end
  end
end
