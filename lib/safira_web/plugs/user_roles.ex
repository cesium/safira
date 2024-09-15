defmodule SafiraWeb.UserRoles do
  use SafiraWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

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
