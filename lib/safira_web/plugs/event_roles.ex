defmodule SafiraWeb.EventRoles do
  alias Phoenix.Router.NoRouteError
  use SafiraWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Used to check if registrations have opened, so users can register / log in
  """
  def registrations_open(conn, _opts) do
    if Application.fetch_env!(:safira, SafiraWeb.Endpoint)[:registrations_open] do
      conn
    else
      raise %Ecto.NoResultsError{}
    end
  end

  def backoffice_enabled(conn, _opts) do
    attendees_allowed =
      is_not_in_future(Application.fetch_env!(:safira, SafiraWeb.Endpoint)[:start_time])

    staff_allowed = Application.fetch_env!(:safira, SafiraWeb.Endpoint)[:backoffice_enabled_staff]

    if (conn.assigns.current_user.type == :attendee and attendees_allowed) or
         (conn.assigns.current_user.type == :staff and staff_allowed) do
      conn
    else
      conn
      |> redirect(to: ~p"/countdown")
      |> halt()
    end
  end

  defp is_not_in_future(time) do
    DateTime.compare(time, DateTime.utc_now()) == :lt
  end
end
