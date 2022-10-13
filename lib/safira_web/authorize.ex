defmodule Safira.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  alias Safira.Repo
  alias Safira.Accounts.User

  @user_types [:attendee, :company, :manager]

  def init(default) do
    default
  end

  def call(conn, param) do
    if is_authorized(conn, param) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end

  defp is_authorized(conn, param) when param in @user_types do
    with %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Repo.preload(param)
      |> Map.fetch!(param)
      |> is_nil
      |> Kernel.not()
    end
  end
end
