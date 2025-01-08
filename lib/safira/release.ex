defmodule Safira.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :safira

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create_root_account(name, email, password, handle, role \\ "Admin") do
    load_app()

    if String.length(password) < 12 do
      raise ArgumentError, "Password must be at least 12 characters long"
    end

    # Fetch all permissions
    permissions = Permissions.all()

    role =
      Safira.Roles.get_role_by_name(role)
      |> case do
        r when r == nil ->
          Safira.Roles.create_role(%{name: role, permissions: permissions}) |> elem(1)

        r ->
          r
      end

    # Create user
    case Safira.Accounts.register_staff_user(%{
           name: name,
           email: email,
           password: password,
           handle: handle
         }) do
      {:ok, user} ->
        # Assign role to user
        Safira.Accounts.create_staff(%{user_id: user.id, role_id: role.id})

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
