defmodule Safira.StoreFactory do
  @moduledoc """
  A factory to build all store related structs
  """

  alias Safira.Store.{Redeemable}
  defmacro __using__(_opts) do
    quote do
      def redeemable_factory do
        %Redeemable{
          name: Faker.Commerce.product_name(),
          description: Faker.StarWars.En.quote(),
          price: Enum.random(10..50),
          max_per_user: Enum.random(1..3)
        }
      end
    end
  end
end
