defmodule SafiraWeb.LeaderboardController do
  use SafiraWeb, :controller

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Contest.list_leaderboard()
    render(conn, SafiraWeb.LeaderboardView, "index.json", attendees: attendees)
  end
end
