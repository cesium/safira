defmodule Safira.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Accounts.User
  alias Safira.Accounts.Attendee

  alias Safira.Guardian

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_preload!(id) do 
    Repo.get!(User, id)
    |> Repo.preload(:attendee)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_uuid(attrs) do
    case get_attendee!(attrs["attendee"]["id"]) do
      %Attendee{} = _attendee ->
        Map.delete(attrs, "attendee") 
        |> create_user
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
