defmodule Safira.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Accounts.User

  alias Safira.Guardian

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_uuid!(uuid), do: Repo.get_by!(User, uuid: uuid)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_uuid(attrs, uuid) do
    case get_by_uuid(uuid) do
      {:ok, user} ->
        User.changeset(user, attrs)
        |> Repo.update()
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

  defp get_by_uuid(uuid) when is_binary(uuid) do
    case Repo.get_by(User, uuid: uuid) do
      nil ->
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end
end
