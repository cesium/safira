defmodule Mix.Tasks.Anonymize.Users do
  @moduledoc """
  Task to anonymize users
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts.{Attendee, User}
  alias Safira.Repo

  def run(_args) do
    Mix.Task.run("app.start")
    users = Enum.shuffle(Repo.all(User))

    for {user, index} <- Enum.with_index(users) do
      anonymize_user(user, index + 1)
    end
  end

  defp anonymize_user(%User{} = user, index) do
    attendee =
      Attendee
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
