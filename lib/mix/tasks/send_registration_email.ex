defmodule Mix.Tasks.Send.RegistrationEmails do
  @moduledoc """
  Task to send registration emails to every attendee
  """
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Auth
  alias Safira.Repo

  def run(args) do
    Mix.Task.run("app.start")

    Accounts.list_users()
    |> Repo.preload(:attendee)
    |> Enum.filter(fn a ->
      a
      |> Map.fetch!(:attendee)
      |> is_nil
      |> Kernel.not()
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
