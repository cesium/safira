defmodule SafiraWeb.AuthController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Guardian

  action_fallback SafiraWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    if user_params["uuid"] do
      with  {:ok, %User{} = user} <- Accounts.create_user_uuid(user_params),
            {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
        conn 
        |> render("jwt.json", jwt: token)
      end
    else
      {:error, :unauthorized}
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "user.json", user: user)
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end  
end
