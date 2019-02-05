defmodule Mix.Tasks.Ban.User do
  use Mix.Task

  alias Safira.Accounts.User
  alias Safira.Accounts

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell.info "Needs to receive one user email."
      true ->
        args |> create
    end
  end

  defp create(args) do
    Mix.Task.run "app.start"
    user = Safira.Repo.get_by(User, email: Enum.at(args, 0))
    if user do
      password = random_string(8)
      u = Accounts.get_user_preload!(user.id)
      u |> Accounts.update_user(%{
            password: password,
            password_confirmation: password,
            ban: true
           })
      u.attendee
      |> Accounts.update_attendee(%{avatar: nil})
    else
      Mix.shell.info "User does not exist!"
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
