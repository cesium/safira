defmodule Mix.Tasks.Send.RegistrationEmails do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Auth

  def run(args) do
    Mix.Task.run("app.start")

    Accounts.list_users()
    |> Enum.filter(fn a ->
      not Accounts.is_manager(a) and not Accounts.is_company(a)
    end)
    |> Enum.each(fn a ->
      send_mail(a)
    end)
  end

  defp send_mail(user) do
    user = Auth.reset_password_token(user)

    Safira.Email.send_registration_email(
      user.email,
      user.reset_password_token
    )
  end
end
