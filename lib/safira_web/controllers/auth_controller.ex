defmodule SafiraWeb.AuthController do
  use SafiraWeb, :controller

  alias Safira.Auth
  alias Safira.Accounts
  alias Safira.Guardian

  action_fallback SafiraWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %{user: user,
          attendee: %{discord_association_code: code}}} <- Auth.create_user_uuid(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> render("signup_response.json", %{jwt: token,
      discord_association_code: code})
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user_preload = Accounts.get_user_preload!(user.id)
    user =
      cond do
        not is_nil user_preload.attendee ->
          user
          |> Map.put(:id, user_preload.id)
          |> Map.put(:type, "attendee")
        not is_nil user_preload.company ->
          user
          |> Map.put(:id, user_preload.id)
          |> Map.put(:type, "company")
        not is_nil user_preload.manager ->
          user
          |> Map.put(:id, user_preload.id)
          |> Map.put(:type, "manager")
      end
    render(conn, "user.json", user: user)
  end

  def attendee(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user_preload = Accounts.get_user_preload!(user.id)
    case is_nil user_preload.attendee do
      true ->
        {:error, :unauthorized}
      false ->
        render(conn, "attendee.json", user: user_preload)
    end
  end

  def company(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user_preload = Accounts.get_user_preload!(user.id)
    case is_nil user_preload.company do
      true ->
        {:error, :unauthorized}
      false ->
        render(conn, "company.json", user: user_preload)
    end
  end

  def is_registered(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    case is_nil attendee do
      true ->
        {:error, :not_found}
      false ->
        render(conn, "is_registered.json", is_registered: not is_nil attendee.user_id)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        render(conn, "jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end
end
