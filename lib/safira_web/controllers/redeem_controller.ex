defmodule SafiraWeb.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Redeem

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    users_badges = Contest.list_users_badges()
    render(conn, "index.json", users_badges: users_badges)
  end

  def create(conn, %{"redeem" => redeem_params}) do
    with {:ok, %Redeem{} = redeem} <- Contest.create_redeem(redeem_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", redeem_path(conn, :show, redeem))
      |> render("show.json", redeem: redeem)
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
