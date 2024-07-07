defmodule Safira.Repo.Seeds.Accounts do
  alias Safira.Accounts
  alias Safira.Repo

  @names File.read!("priv/fake/names.txt") |> String.split("\n")

  def run do
    attendee_names = @names |> Enum.drop(div(length(@names), 2))
    staff_names = @names |> Enum.take(div(length(@names), 2))

    case Accounts.list_attendees() do
      [] ->
        seed_attendees(attendee_names)
      _  ->
        Mix.shell().error("Found staff accounts, aborting seeding staffs.")
    end

    case Accounts.list_staffs() do
      [] ->
        seed_staffs(staff_names)
      _  ->
        Mix.shell().error("Found staff accounts, aborting seeding staffs.")
    end
  end

  def seed_attendees(_names) do
    #TODO: Seed attendees
  end

  def seed_staffs(names) do
    for {name, i} <- Enum.with_index(names) do
      email = "staff#{i}@seium.org"
      handle = name |> String.downcase() |> String.replace(~r/\s/, "_")

      user = %{
        name: name,
        handle: handle,
        email: email,
        password: "password1234"
      }

      case Accounts.register_staff_user(user) do
        {:ok, changeset} ->
          Repo.update!(Accounts.User.confirm_changeset(changeset))
          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end
end

Safira.Repo.Seeds.Accounts.run()
