defmodule Mix.Tasks.Anonimize.Users do
  @moduledoc """
  Task to anonimize users
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts.{Attendee, User}
  alias Safira.Repo

  def run(_args) do
    Mix.Task.run("app.start")
    users = Enum.shuffle(Repo.all(User))
    n = length(users)

    for i <- 0..n-1 do
      anonimze_user(Enum.at(users, i), i + 1)
    end
  end

  defp anonimze_user(%User{} = user, index) do
    attendee = Attendee
      |> where([a], a.user_id == ^user.id)
      |> Repo.one()

    if not is_nil(attendee) do
      attendee
      |> Attendee.changeset(%{
        name: "Attendee #{index}",
        nickname: "attendee#{index}",
        avatar: nil,
        cv: nil
      })
      |> Repo.update!()
    end

    user
    |> User.changeset(%{
      email: "user#{index}@seium.org",
      password: "password1234",
      password_confirmation: "password1234"
    })
    |> Repo.update!()
  end
end
