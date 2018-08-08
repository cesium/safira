defmodule SafiraWeb.AuthController do
  use SafiraWeb, :controller

  alias Safira.Auth
  alias Safira.Guardian
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, multi} <- Auth.create_user_uuid(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(multi.user) do
      conn
      |> render("jwt.json", jwt: token)
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "user.json", user: user)
  end

  def attendee(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user_preload = Safira.Accounts.get_user_preload!(user.id)
    case is_nil user_preload do
      true ->
        {:error, :unauthorized}
      _ ->
        render(conn, "attendee.json", user: user_preload)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end
end
