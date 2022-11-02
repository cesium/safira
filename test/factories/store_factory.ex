defmodule Safira.StoreFactory do
  @moduledoc """
  A factory to build all store related structs
  """

  alias Faker.StarWars.En
  alias Safira.Store.{Buy, Redeemable}

  defmacro __using__(_opts) do
    quote do
      def redeemable_factory do
        %Redeemable{
          name: Faker.Commerce.product_name(),
          description: En.quote(),
          price: Enum.random(10..50),
          max_per_user: Enum.random(1..3),
          stock: Enum.random(4..10)
        }
      end

      def buy_factory do
        %Buy{
          quantity: 1,
          attendee: build(:attendee),
          redeemable: build(:redeemable)
        }
      end
    end
  end
end
