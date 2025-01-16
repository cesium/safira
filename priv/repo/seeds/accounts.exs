defmodule Safira.Repo.Seeds.Accounts do
  alias Safira.Accounts
  alias Safira.Repo
  alias Safira.Roles
  alias Safira.Accounts.{Attendee, User}

  @names File.read!("priv/fake/names.txt") |> String.split("\n")

  def run do
    attendee_names = @names |> Enum.drop(div(length(@names), 2))
    staff_names = @names |> Enum.take(div(length(@names), 2))
    credential_count = 100

    case Accounts.list_attendees() do
      [] ->
        seed_attendees(attendee_names)
      _  ->
        Mix.shell().error("Found attendee accounts, aborting seeding attendees.")
    end

    case Accounts.list_staffs() do
      [] ->
        seed_staffs(staff_names)
      _  ->
        Mix.shell().error("Found staff accounts, aborting seeding staffs.")
    end

    case Accounts.list_credentials() do
      [] ->
        seed_credentials(credential_count, div(attendee_names |> length(), 2))
      _ ->
        Mix.shell().error("Found credentials, aborting seeding credentials.")
    end
  end

  def seed_attendees(names) do
    courses = Accounts.list_courses()

    for {name, i} <- Enum.with_index(names) do
      email = "attendee#{i}@seium.org"
      handle = name |> String.downcase() |> String.replace(~r/\s/, "_")

      attrs = %{
        "name" => name,
        "handle" => handle,
        "email" => email,
        "password" => "password1234",
        "password_confirmation" => "password1234",
        "attendee" => %{
          "course_id" => Enum.random(courses).id,
          "tokens" => :rand.uniform(999),
          "entries" => :rand.uniform(200)
        }
      }


      case User.registration_changeset(%User{}, Map.delete(attrs, "attendee")) |> Repo.insert() do
        {:ok, user} ->
          case Attendee.changeset(%Attendee{}, Map.put(Map.get(attrs, "attendee"), "user_id", user.id)) |> Repo.insert() do
            {:ok, _attendee} ->
              Repo.update!(Accounts.User.confirm_changeset(user))
            {:error, changeset} ->
              Mix.shell().error(Kernel.inspect(changeset.errors))
          end
        {:error, changeset} ->
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_staffs(names) do
    roles = Roles.list_roles()

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
          Accounts.create_staff(%{user_id: user.id, role_id: Enum.random(roles).id})
          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_credentials(credential_count, attendee_to_link_count) do
    attendees = Accounts.list_attendees()

    for i <- 0..credential_count do
      id = if i < attendee_to_link_count do Enum.at(attendees, i).attendee.id else nil end
      Accounts.create_credential(%{attendee_id: id})
    end
  end
end

Safira.Repo.Seeds.Accounts.run()
