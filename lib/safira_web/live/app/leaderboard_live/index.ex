defmodule SafiraWeb.App.LeaderboardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  import SafiraWeb.App.LeaderboardLive.Components.Leaderboard

  @limit 5

  @impl true
  def mount(_params, _session, socket) do
    leaderboard = Contest.daily_leaderboard(DateTime.utc_now(), @limit)

    user_position =
      Contest.daily_leaderboard_position(
        DateTime.utc_now(),
        socket.assigns.current_user.attendee.id
      )

    {:ok,
     socket
     |> assign(:leaderboard, leaderboard)
     |> assign(:current_page, :leaderboard)
     |> assign(:user_position, user_position)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
