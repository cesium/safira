defmodule SafiraWeb.EventRoles do
  alias Phoenix.Router.NoRouteError
  use SafiraWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Safira.Constants
  alias SafiraWeb.Helpers

  @doc """
  Used to check if registrations have opened, so users can register / log in
  """
  def registrations_open(conn, _opts) do
    {:ok, open} = Constants.get("REGISTRATIONS_OPEN")

    if open do
      conn
    else
      raise %Ecto.NoResultsError{}
    end
  end

  @doc """
  Used to check if attendees can already access the backoffice
  """
  def backoffice_enabled(conn, _opts) do
    attendees_allowed =
      is_not_in_future(Helpers.get_start_time!())

    if conn.assigns.current_user.type == :attendee and not attendees_allowed do
      conn
      |> redirect(to: ~p"/waiting/countdown")
      |> halt()
    else
      conn
    end
  end

  defp is_not_in_future(time) do
    DateTime.compare(time, DateTime.utc_now()) == :lt
  end
end
