defmodule Safira.UserStrategy do
  use ExMachina.Strategy, function_name: :create_user_strategy

  def handle_create_user_strategy(record, _opts) do
    {:ok, user} = Safira.Accounts.create_user(
                    %{email: record.email, 
                      password: record.password,
                      password_confirmation: record.password})
    user
  end
end
