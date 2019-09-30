defmodule Safira.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Safira.Accounts.User{
          email: sequence(:email, &"email#{&1}@safira.safira"),
          password: "test12345"
        }
      end
    end
  end
end
