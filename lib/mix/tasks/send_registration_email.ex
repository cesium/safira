defmodule Mix.Tasks.Send.RegistrationEmails do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Contest.Badge

  def run(args) do
    Mix.Task.run("app.start")

    with _badge = %Badge{} <- Contest.get_badge!(badge_id) do
      Accounts.list_users()
      |> Enum.each(fn a ->
        send_mail(a)
      end)
    end
  end

  defp send_mail(user) do
    user = Auth.reset_password_token(user)

    Safira.Email.send_registration_email(
      user.email,
      user.reset_password_token
    )
  end
end
