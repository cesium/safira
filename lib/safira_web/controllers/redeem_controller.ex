defmodule SafiraWeb.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  plug Safira.Authorize, :manager

  def create(conn, %{"redeem" => redeem_params}) do
    user = Guardian.Plug.current_resource(conn)
    |> Map.get(:id)
    |> Accounts.get_user_preload!
    case Map.fetch(redeem_params,"badge_id") do
      {:ok, id} ->
        Contest.get_badge!(id)
        redeem_params = Map.put(redeem_params, "manager_id", user.manager.id)
        with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
          conn
          |> put_status(:created)
          |> json(%{redeem: "Badge redeem successfully"})
        end
      _ ->
        {:error, :not_found}
    end
  end
end
