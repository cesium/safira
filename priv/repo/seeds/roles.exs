defmodule Safira.Repo.Seeds.Roles do
  alias Safira.Accounts.Role
  alias Safira.Accounts.Roles.Permissions
  alias Safira.Repo
  alias Safira.Roles

  def run do
    case Roles.list_roles() do
      [] ->
        seed_roles()
      _  ->
        Mix.shell().error("Found roles, aborting seeding roles.")
    end
  end

  def seed_roles do
    permissions = Permissions.all()

    roles = [
      %{
        name: "Admin",
        permissions: permissions
      }
    ]

    Enum.each(roles, fn role ->
      role = Role.changeset(%Role{}, role)
      Repo.insert(role)
    end)
  end
end

Safira.Repo.Seeds.Roles.run()
