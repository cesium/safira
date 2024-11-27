defmodule SafiraWeb.EventRoles do
  @moduledoc false
  use SafiraWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Safira.Event

  @doc """
  Used to check if registrations have opened, so users can register / log in
  """
  def registrations_open(conn, _opts) do
    if Event.registrations_open?() do
      conn
    else
      raise %Ecto.NoResultsError{}
    end
  end

  @doc """
  Used to check if attendees can already access the backoffice
  """
  def backoffice_enabled(conn, _opts) do
    if Event.event_started?() do
      conn
    else
      conn
      |> redirect(to: ~p"/app/waiting")
      |> halt()
    end
  end
end
