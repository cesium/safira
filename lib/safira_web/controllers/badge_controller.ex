defmodule SafiraWeb.BadgeController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts
  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    cond do
      Accounts.is_admin(conn) ->
        badges = Contest.list_badges()
        render(conn, "index.json", badges: badges)

      Accounts.is_manager(conn) ->
        badges = Contest.list_available_badges()
        render(conn, "index.json", badges: badges)

      true ->
        badges = Contest.list_badges_conservative()
        render(conn, "index.json", badges: badges)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Contest.get_badge_preload!(id)
    render(conn, "show.json", badge: badge)
  end
end
