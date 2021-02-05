defmodule SafiraWeb.LeaderboardController do
  use SafiraWeb, :controller

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Contest.list_leaderboard()
    render(conn, SafiraWeb.LeaderboardView, "index.json", attendees: attendees)
  end

  def daily(conn, %{"date" => date_params}) do
    case Date.from_iso8601(date_params) do
      {:ok, result} ->

        attendees = Contest.list_daily_leaderboard(result)
        #IO.inspect(attendees)
        render(conn, SafiraWeb.LeaderboardView, "index.json", attendees: attendees)

      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Date should be in {YYYY}-{MM}-{DD} format"})
    end
  end
end
