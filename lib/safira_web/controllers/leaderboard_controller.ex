defmodule SafiraWeb.LeaderboardController do
  use SafiraWeb, :controller

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    board = Contest.list_leaderboard()

    attendees =
      board
      |> Enum.map(fn a ->
        %{
          badge_count: a.badge_count,
          attendee: Map.put(a.attendee, :token_balance, a.token_count)
        }
      end)
      |> Enum.map(fn a -> Map.put(a.attendee, :badge_count, a.badge_count) end)

    render(conn, SafiraWeb.LeaderboardView, "index.json", attendees: attendees)
  end

  def daily(conn, %{"date" => date_params}) do
    case Date.from_iso8601(date_params) do
      {:ok, result} ->
        board = Contest.list_daily_leaderboard(result)

        attendees =
          board
          |> Enum.map(fn a ->
            %{
              badge_count: a.badge_count,
              attendee: Map.put(a.attendee, :token_balance, a.token_count)
            }
          end)
          |> Enum.map(fn a -> Map.put(a.attendee, :badge_count, a.badge_count) end)

        render(conn, SafiraWeb.LeaderboardView, "index.json", attendees: attendees)

      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Date should be in {YYYY}-{MM}-{DD} format"})
    end
  end
end
