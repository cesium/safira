defmodule SafiraWeb.PageController do
  use SafiraWeb, controller: "1.6"

  def index(conn, _params) do
    conn
    |> json(%{safira: "Check the bottom of the sea"})
  end
end
