defmodule SafiraWeb.AuthController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Auth
  alias Safira.Guardian
  alias Safira.Roulette
  alias Safira.Store

  action_fallback SafiraWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %{user: user, attendee: %{discord_association_code: code}}} <-
           Auth.create_user_uuid(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> render(:signup_response, %{jwt: token, discord_association_code: code})
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user_preload = Accounts.get_user_preload!(user.id)

    user_preload =
      cond do
        not is_nil(user_preload.attendee) ->
          attendee = Accounts.get_attendee_with_badge_count_by_id!(user_preload.attendee.id)

          attendee =
            attendee
            |> Map.put(:redeemables, Store.get_attendee_redeemables(attendee))
            |> Map.put(:prizes, Roulette.get_attendee_prize(attendee))

          user_preload
          |> Map.put(:attendee, attendee)
          |> Map.put(:type, "attendee")

        not is_nil(user_preload.company) ->
          user_preload
          |> Map.put(:type, "company")

        not is_nil(user_preload.staff) ->
          user_preload
          |> Map.put(:type, "staff")
      end

    render(conn, :data, user: user_preload)
  end

  def is_registered(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)

    case is_nil(attendee) do
      true ->
        {:error, :not_found}

      false ->
        render(conn, :is_registered, is_registered: not is_nil(attendee.user_id))
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        render(conn, :jwt, jwt: token)

      _ ->
        {:error, :unauthorized}
    end
  end
end
