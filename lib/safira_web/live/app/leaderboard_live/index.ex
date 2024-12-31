defmodule SafiraWeb.App.LeaderboardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  import SafiraWeb.App.LeaderboardLive.Components.Leaderboard
  import SafiraWeb.App.LeaderboardLive.Components.DaySelector

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
     |> assign(:user_position, user_position)
     |> assign(:current_day_str, "Global")
     |> assign(:current_day_index, -1)
     |> assign(:days, [
       ~N[2024-12-31 00:00:00]
     ])
     |> assign(:left_enabled, false)
     |> assign(:right_enabled, true)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("on_left", _, socket) do
    if socket.assigns.current_day_index > -1 do
      {:noreply,
       socket
       |> assign(:current_day_index, socket.assigns.current_day_index - 1)
       |> assign(
         :current_day_str,
         display_current_day(socket.assigns.days, socket.assigns.current_day_index - 1)
       )
       |> assign(:left_enabled, socket.assigns.current_day_index != 0)
       |> assign(:right_enabled, true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("on_right", _, socket) do
    # TODO: Remove hardcoded 4
    if socket.assigns.current_day_index < 0 do
      {:noreply,
       socket
       |> assign(:current_day_index, socket.assigns.current_day_index + 1)
       |> assign(
         :current_day_str,
         display_current_day(socket.assigns.days, socket.assigns.current_day_index + 1)
       )
       |> assign(:left_enabled, true)
       |> assign(:right_enabled, socket.assigns.current_day_index < -1)}
    else
      {:noreply, socket}
    end
  end

  defp display_current_day(days, index) do
    if index == -1 do
      "Global"
    else
      days
      |> Enum.at(index)
      |> format_date()
    end
  end

  def format_date(date) do
    today = Timex.today()
    yesterday = Timex.shift(today, days: -1)

    cond do
      Timex.equal?(date, today) ->
        "Today"

      Timex.equal?(date, yesterday) ->
        "Yesterday"

      true ->
        Timex.format!(date, "{D} {Mshort}")
    end
  end
end
