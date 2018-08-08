defmodule Safira.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Accounts.User
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Manager
  alias Safira.Accounts.Company

  alias Safira.Guardian

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_preload!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:attendee)
    |> Repo.preload(:company)
    |> Repo.preload(:manager)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_uuid(attrs) do
    Repo.transaction(fn ->
      case logic_user_uuid(attrs) do
        {:ok, %User{} = user} ->
          case update_attendee_uuid(Map.put(attrs["attendee"], "user_id", user.id)) do
            {:ok, %Attendee{} = _attendee} -> user
            _ -> Repo.rollback(:unauthorized)
          end
        {:error, _} -> Repo.rollback(:unauthorized)
      end      
    end)
  end

  defp logic_user_uuid(attrs) do
    case get_attendee!(attrs["attendee"]["id"]) do
      %Attendee{} = attendee ->
        if is_nil attendee.user_id do
          Map.delete(attrs, "attendee")
          |> create_user
        else
          {:error, :unauthorized}
        end
      _ ->
        {:error, :unauthorized}
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_attendees do
    Repo.all(Attendee)
  end

  def get_attendee!(id), do: Repo.get!(Attendee, id)

  def create_attendee(attrs \\ %{}) do
    %Attendee{}
    |> Attendee.changeset(attrs)
    |> Repo.insert()
  end

  def update_attendee(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.changeset(attrs)
    |> Repo.update()
  end

  def update_attendee_uuid(attrs) do
    get_attendee!(attrs["id"])
    |> update_attendee(attrs)
  end

  def delete_attendee(%Attendee{} = attendee) do
    Repo.delete(attendee)
  end

  def change_attendee(%Attendee{} = attendee) do
    Attendee.changeset(attendee, %{})
  end

  def is_volunteer(%Attendee{} = attendee) do
    attendee.volunteer
  end

  def list_managers do
    Repo.all(Manager)
  end

  def get_manager!(id), do: Repo.get!(Manager, id)

  def create_manager(attrs \\ %{}) do
    %Manager{}
    |> Manager.changeset(attrs)
    |> Repo.insert()
  end

  def update_manager(%Manager{} = manager, attrs) do
    manager
    |> Manager.changeset(attrs)
    |> Repo.update()
  end

  def delete_manager(%Manager{} = manager) do
    Repo.delete(manager)
  end

  def change_manager(%Manager{} = manager) do
    Manager.changeset(manager, %{})
  end

  def list_companies do
    Repo.all(Company)
  end

  def get_company!(id), do: Repo.get!(Company, id)

  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
    do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
