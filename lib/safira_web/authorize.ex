defmodule Safira.Authorize do
  import Plug.Conn
  import Phoenix.Controller
  
  alias Safira.Repo
  alias Safira.Accounts.User

  def init(_params) do
  end

  def call(conn, _params) do
    if is_authorized(conn) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end

  defp is_authorized(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user 
      |> Repo.preload(:manager)
      not is_nil user.manager
    end
  end
end
