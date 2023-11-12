defmodule Safira.Repo.Seeds.Accounts do
  @moduledoc false

  alias Mix.Tasks.Gen.{AttendeesWithPassword, Companies, Staffs}
  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Repo

  def run do
    seed_staffs()
    seed_companies()
    seed_attendees()
    reset_passwords()
  end

  defp seed_companies do
    Companies.run(["data/sponsors.csv"])
  end

  defp seed_staffs do
    Staffs.run(["10"])
  end

  defp seed_attendees do
    AttendeesWithPassword.run(["100"])
  end

  # All tasks generate random passwords, which is not very useful in a development
  # environment. So this function changes the passwords of all users to "password1234"
  defp reset_passwords do
    Accounts.list_users()
    |> Enum.each(fn u -> Repo.update(User.update_password_changeset(u, %{password: "password1234"})) end)
  end
end

Safira.Repo.Seeds.Accounts.run()
