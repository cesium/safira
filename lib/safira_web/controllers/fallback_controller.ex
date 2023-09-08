defmodule SafiraWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SafiraWeb, :controller

  alias SafiraWeb.ErrorJSON

  def call(conn, {:error, :register_error}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid register data"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Login error"})
  end

  def call(conn, {:error, :not_registered}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Attendee needs to be registered"})
  end

  def call(conn, {:error, :has_user}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Already registered"})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_view(json: ErrorJSON)
    |> put_status(:unprocessable_entity)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    require Logger
    Logger.warn("BATATA")

    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:not_found)
  end

  def call(conn, {:error, :no_permission}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "You have no permission to do this"})
  end
end
