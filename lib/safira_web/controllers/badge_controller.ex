defmodule SafiraWeb.BadgeController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Badge

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    badges = Contest.list_badges()
    render(conn, "index.json", badges: badges)
  end

  def create(conn, %{"badge" => badge_params}) do
    with {:ok, %Badge{} = badge} <- Contest.create_badge(badge_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", badge_path(conn, :show, badge))
      |> render("show.json", badge: badge)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    render(conn, "show.json", badge: badge)
  end

  def update(conn, %{"id" => id, "badge" => badge_params}) do
    badge = Contest.get_badge!(id)

    with {:ok, %Badge{} = badge} <- Contest.update_badge(badge, badge_params) do
      render(conn, "show.json", badge: badge)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    with {:ok, %Badge{}} <- Contest.delete_badge(badge) do
      send_resp(conn, :no_content, "")
    end
  end
end
