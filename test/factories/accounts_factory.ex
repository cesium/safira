defmodule Safira.AccountsFactory do
  @moduledoc """
  A factory to build all accounts related structs
  """
  defmacro __using__(_opts) do
    quote do
      def attendee_factory do
        first_name = Faker.Person.PtBr.first_name()
        last_name = Faker.Person.PtBr.last_name()

        %Safira.Accounts.Attendee{
          nickname: String.downcase("#{first_name}_#{last_name}"),
          name: "#{first_name} #{last_name}",
          volunteer: Enum.random([true, false]),
          user: build(:user)
        }
      end

      def company_factory do
        name = Faker.Company.name()

        %Safira.Accounts.Company{
          name: name,
          sponsorship: Enum.random(["exclusive", "gold", "silver", "bronze"]),
          channel_id: String.downcase(name),
          user: build(:user)
        }
      end

      def manager_factory do
        %Safira.Accounts.Manager{
          active: Enum.random([true, false]),
          is_admin: Enum.random([true, false]),
          user: build(:user)
        }
      end

      def user_factory do
        %Safira.Accounts.User{
          email: sequence(:email, &"email#{&1}@mail.com"),
          password: "password1234!"
        }
      end
    end
  end
end
