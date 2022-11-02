defmodule Safira.AuthErrorHandler do
  @moduledoc false
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{error: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, body)
  end
end
