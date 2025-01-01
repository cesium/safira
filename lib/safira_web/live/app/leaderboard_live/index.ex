defmodule SafiraWeb.App.LeaderboardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  import SafiraWeb.App.LeaderboardLive.Components.Leaderboard
  import SafiraWeb.App.LeaderboardLive.Components.DaySelector
  import SafiraWeb.App.LeaderboardLive.Components.Prizes

  @limit 5

  @impl true
  def mount(_params, _session, socket) do
    leaderboard = Contest.leaderboard(nil, @limit)

    user_position =
      Contest.leaderboard_position(
        nil,
        socket.assigns.current_user.attendee.id
      )

    daily_prizes = Contest.list_daily_prizes()

    days =
      daily_prizes
      |> Enum.flat_map(fn dp ->
        if is_nil(dp.date) do
          []
        else
          [dp.date]
        end
      end)
      |> Enum.dedup()

    {:ok,
     socket
     |> assign(:leaderboard, leaderboard)
     |> assign(:current_page, :leaderboard)
     |> assign(:user_position, user_position)
     |> assign(:current_day_str, "Global")
     |> assign(:current_day_index, -1)
     |> assign(:days, days)
     |> assign(:left_enabled, false)
     |> assign(:right_enabled, true)
     |> assign(:daily_prizes, daily_prizes)
     |> assign(:prizes, get_day_prizes(daily_prizes, nil))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("on_left", _, socket) do
    if socket.assigns.current_day_index > -1 do
      day = get_day(socket.assigns.days, socket.assigns.current_day_index - 1)

      {:noreply,
       socket
       |> assign(:current_day_index, socket.assigns.current_day_index - 1)
       |> assign(
         :current_day_str,
         display_current_day(socket.assigns.days, socket.assigns.current_day_index - 1)
       )
       |> assign(:left_enabled, socket.assigns.current_day_index != 0)
       |> assign(:right_enabled, true)
       |> assign(:prizes, get_day_prizes(socket.assigns.daily_prizes, day))
       |> assign(
         :user_position,
         Contest.leaderboard_position(day, socket.assigns.current_user.attendee.id)
       )
       |> assign(:leaderboard, Contest.leaderboard(day, @limit))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("on_right", _, socket) do
    if socket.assigns.current_day_index < length(socket.assigns.days) - 1 do
      day = get_day(socket.assigns.days, socket.assigns.current_day_index + 1)

      {:noreply,
       socket
       |> assign(:current_day_index, socket.assigns.current_day_index + 1)
       |> assign(
         :current_day_str,
         display_current_day(socket.assigns.days, socket.assigns.current_day_index + 1)
       )
       |> assign(:left_enabled, true)
       |> assign(
         :right_enabled,
         socket.assigns.current_day_index < length(socket.assigns.days) - 2
       )
       |> assign(:prizes, get_day_prizes(socket.assigns.daily_prizes, day))
       |> assign(
         :user_position,
         Contest.leaderboard_position(day, socket.assigns.current_user.attendee.id)
       )
       |> assign(:leaderboard, Contest.leaderboard(day, @limit))}
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

  defp get_day(days, index) do
    if index == -1 do
      nil
    else
      Enum.at(days, index)
    end
  end

  defp format_date(date) do
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

  defp get_day_prizes(daily_prizes, day) do
    daily_prizes
    |> Enum.filter(fn dp ->
      if is_nil(day) do
        is_nil(dp.date)
      else
        dp.date == day
      end
    end)
  end
end
