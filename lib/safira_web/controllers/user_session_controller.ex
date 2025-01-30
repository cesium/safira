defmodule SafiraWeb.UserSessionController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias SafiraWeb.UserAuth

  def new(conn, %{"user" => user_params}) do
    case Accounts.register_attendee_user(user_params) do
      {:ok, %{user: user, attendee: _}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> UserAuth.log_in_user(user, user_params)
        |> put_flash(:success, "Account created successfully")
        |> redirect(to: ~p"/app")

      {:error, _, %Ecto.Changeset{} = _changeset, _} ->
        conn
        |> put_flash(:error, "Unable to register. This email may already be registered.")
        |> redirect(to: ~p"/users/register")
    end
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params, "action" => action, "action_id" => action_id}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
      |> process_action(action, action_id, user)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in?action=#{action}&action_id=#{action_id}")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  defp process_action(conn, "enrol", id, user) do
    attendee = Safira.Accounts.get_user_attendee(user.id)
    case Safira.Activities.enrol(attendee.id, id) do
      {:ok, _}  ->
        put_flash(conn, :info, gettext("Successfully enrolled"))
      {:error, _, _, _} ->
        put_flash(conn, :error, gettext("Unable to enrol"))
    end
  end

  defp process_action(conn, _action, _id, _user), do: conn
end
