defmodule SafiraWeb.LeaderboardController do
  use SafiraWeb, :controller

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Accounts.list_leaderboard()
    render(conn, SafiraWeb.AttendeeView, "index.json", attendees: attendees)
  end
end
