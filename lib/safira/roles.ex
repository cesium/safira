defmodule Safira.Roles do
  @moduledoc """
    The Roles context.
  """

  use Safira.Context
  alias Safira.Accounts.Role

  @doc """
    Returns the list of roles.

    ## Examples

        iex> list_roles()
        [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
    Gets a single role.

    Raises `Ecto.NoResultsError` if the Role does not exist.

    ## Examples

        iex> get_role!(123)
        %Role{}

        iex> get_role!(456)
        ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
    Gets a role by name.

    Raises `Ecto.NoResultsError` if the Role does not exist.

    ## Examples

        iex> get_role_by_name!("admin")
        %Role{}

        iex> get_role_by_name!("user")
        ** (Ecto.NoResultsError)
  """
  def get_role_by_name!(name) do
    Repo.get_by!(Role, name: name)
  end

  @doc """
    Gets a role by name.

    ## Examples

        iex> get_role_by_name("admin")
        %Role{}

        iex> get_role_by_name("user")
        nil
  """
  def get_role_by_name(name) do
    Repo.get_by(Role, name: name)
  end

  @doc """
    Creates a role.

    ## Examples

        iex> create_role(%{field: value})
        {:ok, %Role{}}

        iex> create_role(%{field: bad_value})
        {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
    Updates a role.

    ## Examples

        iex> update_role(role, %{field: value})
        {:ok, %Role{}}

        iex> update_role(role, %{field: bad_value})
        {:error, %Ecto.Changeset{}}

  """
  def update_role(role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
    Changes a role.

    ## Examples

        iex> change_role(role, %{field: value})
        %Ecto.Changeset{}

  """
  def change_role(role, attrs) do
    Role.changeset(role, attrs)
  end

  @doc """
    Deletes a role.

    ## Examples

        iex> delete_role(role)
        {:ok, %Role{}}

  """
  def delete_role(role) do
    Repo.delete(role)
  end

  @doc """
    Adds a permission to a role.

    ## Examples

        iex> add_permission(role, "permission")
        {:ok, %Role{}}

  """
  def add_permission(role, permission) do
    role
    |> Role.changeset(%{permissions: Map.put(role.permissions, permission, true)})
    |> Repo.update()
  end

  @doc """
    Removes a permission from a role.

    ## Examples

        iex> remove_permission(role, "permission")
        {:ok, %Role{}}

  """
  def remove_permission(role, permission) do
    role
    |> Role.changeset(%{permissions: Map.delete(role.permissions, permission)})
    |> Repo.update()
  end

  @doc """
    Checks if a role has a permission.

    ## Examples

        iex> has_permission?(role, "permission")
        true

  """
  def has_permission?(role, permission) do
    Map.has_key?(role.permissions, permission)
  end
end
