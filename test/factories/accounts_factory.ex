defmodule Safira.AccountsFactory do
  @moduledoc """
  A factory to build all accounts related structs
  """

  alias Faker.Person.En

  defmacro __using__(_opts) do
    quote do
      def attendee_factory do
        first_name = En.first_name()
        last_name = En.last_name()

        %Safira.Accounts.Attendee{
          nickname: String.downcase("#{first_name}_123"),
          name: "#{first_name} #{last_name}",
          user: build(:user)
        }
      end

      def company_factory do
        name = Faker.Company.name()

        %Safira.Accounts.Company{
          name: name,
          sponsorship: Enum.random(["exclusive", "gold", "silver", "bronze"]),
          channel_id: String.downcase(name),
          user: build(:user),
          badge: build(:badge),
          has_cv_access: Enum.random([true, false])
        }
      end

      def staff_factory do
        %Safira.Accounts.Staff{
          active: Enum.random([true, false]),
          is_admin: Enum.random([true, false]),
          user: build(:user)
        }
      end

      def user_factory do
        %Safira.Accounts.User{
          email: sequence(:email, &"email#{&1}@mail.com"),
          password: "password1234!",
          password_confirmation: "password1234!"
        }
      end
    end
  end
end
