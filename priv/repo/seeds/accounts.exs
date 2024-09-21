defmodule Safira.Repo.Seeds.Accounts do
  alias Safira.Accounts
  alias Safira.Repo

  @names File.read!("priv/fake/names.txt") |> String.split("\n")

  def run do
    attendee_names = @names |> Enum.drop(div(length(@names), 2))
    staff_names = @names |> Enum.take(div(length(@names), 2))
    credential_count = 100

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

    case Accounts.list_credentials() do
      [] ->
        seed_credentials(credential_count)
      _ ->
        Mix.shell().erroring("Found credentials, aborting seeding credentials.")
    end
  end

  def seed_attendees(names) do
    for {name, i} <- Enum.with_index(names) do
      email = "attendee#{i}@seium.org"
      handle = name |> String.downcase() |> String.replace(~r/\s/, "_")

      user = %{
        name: name,
        handle: handle,
        email: email,
        password: "password1234"
      }

      case Accounts.register_attendee_user(user) do
        {:ok, changeset} ->
          user = Repo.update!(Accounts.User.confirm_changeset(changeset))
          Accounts.create_attendee(%{user_id: user.id, tokens: :rand.uniform(999), entries: :rand.uniform(200)})
        {:error, changeset} ->
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
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
          user = Repo.update!(Accounts.User.confirm_changeset(changeset))
          Accounts.create_staff(%{user_id: user.id})
          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_credentials(credential_count) do
    for i <- 0..credential_count do
      Accounts.create_credential(%{attendee_id: nil})
    end
  end
end

Safira.Repo.Seeds.Accounts.run()
