defmodule Safira.Auth do
  import Ecto.Query, warn: false
  alias Safira.Repo
  alias Ecto.Multi

  alias Safira.Accounts.User
  alias Safira.Accounts.Attendee
  alias Safira.Accounts

  alias Safira.Guardian

  def create_user_uuid(attrs) do
    if is_nil(attrs["attendee"]["id"]) do
        {:error, :unauthorized}
    else
        case Accounts.get_attendee(attrs["attendee"]["id"]) do
          %Attendee{} = attendee ->
            if is_nil attendee.user_id do
              case Repo.transaction(logic_user_uuid(attrs)) do
                {:ok, result} -> {:ok, result}
                {:error, _} -> {:error, :register_error}
                {:error, _, _, _} -> {:error, :register_error}
              end
            else
              {:error, :has_user}
            end
          _ ->
            {:error, :unauthorized}
        end
    end
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end

  defp logic_user_uuid(attrs) do
    Multi.new
    |> Multi.insert(:user, User.changeset(%User{}, Map.delete(attrs, "attendee")))
    |> Multi.run(:attendee, &add_user_attendee(&1, attrs))
  end

  defp add_user_attendee(multi, attrs) do
    Accounts.get_attendee!(attrs["attendee"]["id"])
    |> Accounts.update_attendee(Map.put(attrs["attendee"], "user_id", multi.user.id))
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

  def random_string(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64
    |> binary_part(0, len)
  end

  ## PasswordReset

  # checks if now is later than 1 day from the reset_token_sent_at
  def expired?(datetime) do
    Timex.after?(Timex.now, Timex.shift(datetime, days: 1))
  end

  # sets the token & sent at in the database for the user
  def reset_password_token(user) do
    token = random_string(48)
    sent_at = DateTime.utc_now

    user
    |> User.password_token_changeset(
      %{reset_password_token: token, reset_token_sent_at: sent_at})
    |> Repo.update!
  end
end
