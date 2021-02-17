defmodule SafiraWeb.BuyController do
  use SafiraWeb, :controller

  alias Safira.Store
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def create(conn, %{"redeemable" => redeemable_params}) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)

    cond do
      not is_nil(attendee) ->
        with {:ok, changes} <- buy_aux(conn, attendee, redeemable_params) do
          conn
          |> put_status(:ok)
          |> json(%{Redeemable: "#{Map.get(changes, :redeemable).name} bought successfully!"})
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Only attendees can buy products!"})
    end
  end

  defp buy_aux(conn, attendee, redeemable_params) do
    case Map.get(redeemable_params, "redeemable_id") do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "No 'redeemable_id' param"})

      redeemable_id ->
        Store.buy_redeemable(redeemable_id, attendee)
    end
  end
end
