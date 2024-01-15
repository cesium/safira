defmodule SafiraWeb.PageController do
  use SafiraWeb, :controller

  def index(conn, _params) do
    conn
    |> json(%{safira: "Check the bottom of the sea"})
  end
end
