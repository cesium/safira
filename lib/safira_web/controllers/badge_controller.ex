defmodule SafiraWeb.BadgeController do
  use SafiraWeb, :controller

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    badges = Contest.list_badges()
    render(conn, "index.json", badges: badges)
  end

  def show(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    render(conn, "show.json", badge: badge)
  end
end
