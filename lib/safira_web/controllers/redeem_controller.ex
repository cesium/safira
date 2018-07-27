defmodule SafiraWeb.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  plug Safira.Authorize, :manager

  def index(conn, _params) do
    redeems = Contest.list_redeems()
    render(conn, "index.json", redeems: redeems)
  end

  def create(conn, %{"redeem" => redeem_params}) do
    user = Guardian.Plug.current_resource(conn)
    |> Map.get(:id)
    |> Accounts.get_user_preload!
    redeem_params = Map.put(redeem_params, "manager_id", user.manager.id)
    with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
      conn
      |> put_status(:created)
      |> json(%{redeem: "Badge redeem successfully"})
    end
  end

  def show(conn, %{"id" => id}) do
    redeem = Contest.get_redeem!(id)
    render(conn, "show.json", redeem: redeem)
  end

  def update(conn, %{"id" => id, "redeem" => redeem_params}) do
    redeem = Contest.get_redeem!(id)

    with {:ok, %Redeem{} = redeem} <- Contest.update_redeem(redeem, redeem_params) do
      render(conn, "show.json", redeem: redeem)
    end
  end

  def delete(conn, %{"id" => id}) do
    redeem = Contest.get_redeem!(id)
    with {:ok, %Redeem{}} <- Contest.delete_redeem(redeem) do
      send_resp(conn, :no_content, "")
    end
  end
end
