defmodule SafiraWeb.BuyController do
  use SafiraWeb, :controller

  alias Safira.Accounts

  alias Safira.Store

  action_fallback SafiraWeb.FallbackController

  def create(conn, %{"redeemable" => redeemable_params}) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)

    if is_nil(attendee) do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Only attendees can buy products!"})
    else
      with {:ok, changes} <- buy_aux(conn, attendee, redeemable_params) do
        conn
        |> put_status(:ok)
        |> json(%{Redeemable: "#{Map.get(changes, :redeemable).name} bought successfully!"})
      end
    end
  end

  defp buy_aux(conn, attendee, redeemable_params) do
    case Map.get(redeemable_params, "redeemable_id") do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "No 'redeemable_id' param"})

      redeemable_id ->
        if Store.exist_redeemable(redeemable_id) do
          case Store.buy_redeemable(redeemable_id, attendee) do
            {:ok, changes} ->
              {:ok, changes}

            {:error, _, changes, _} ->
              {:error, changes}
          end
        else
          conn
          |> put_status(:not_found)
          |> json(%{Redeemable: "There is no such redeemable"})
        end
    end
  end
end
