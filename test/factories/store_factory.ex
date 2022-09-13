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
          price: Enum.random(0..10),
          stock: Enum.random(0..30),
          max_per_user: Enum.random(0..3)
        }
      end
    end
  end
end
