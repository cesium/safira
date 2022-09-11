defmodule Safira.CompanyFactory do
  @moduledoc """
  A factory to build all company related structs
  """

  defmacro __using__(_opts) do
    quote do
      def company_factory do
        name = Faker.Company.name()

        %Safira.Accounts.Company{
          name: name,
          sponsorship: Enum.random(["exclusive", "gold", "silver", "bronze"]),
          channel_id: String.downcase(name),
          user: build(:user),
          badge: build(:badge)
        }
      end
    end
  end
end
