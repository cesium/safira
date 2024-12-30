defmodule SafiraWeb.App.LeaderboardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  @impl true
  def mount(_params, _session, socket) do
    leaderboard = Contest.daily_leaderboard(DateTime.utc_now())

    {:ok,
     socket
     |> assign(:leaderboard, leaderboard)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
