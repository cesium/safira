defmodule SafiraWeb.UserRoles do
  @moduledoc """
  Plugs for user type verification.
  """
  use SafiraWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Safira.Accounts

  def require_credential(conn, _opts) do
    if is_nil(conn.assigns.current_user.attendee) or
         not is_nil(Accounts.get_credential_of_attendee(conn.assigns.current_user.attendee)) do
      conn
    else
      conn
      |> put_flash(
        :error,
        "You haven't assigned a credential to your account. You need one to participate in SEI"
      )
      |> redirect(to: ~p"/scanner")
      |> halt()
    end
  end

  @doc """
  Used for routes that require the user to be an attendee.
  """
  def require_attendee_user(conn, _opts) do
    require_user_type(conn, :attendee)
  end

  @doc """
  Used for routes that require the user to be staff.
  """
  def require_staff_user(conn, _opts) do
    require_user_type(conn, :staff)
  end

  defp require_user_type(conn, type) do
    if conn.assigns[:current_user].type == type do
      conn
    else
      conn
      |> put_flash(:error, "You don't have access to this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
