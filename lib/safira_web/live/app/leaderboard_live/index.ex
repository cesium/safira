defmodule SafiraWeb.App.LeaderboardLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Contest

  import SafiraWeb.App.LeaderboardLive.Components.Leaderboard
  import SafiraWeb.App.LeaderboardLive.Components.DaySelector
  import SafiraWeb.App.LeaderboardLive.Components.Prizes

  @limit 5

  @impl true
  def mount(_params, _session, socket) do
    daily_prizes = Contest.list_daily_prizes()

    days =
      daily_prizes
      |> Enum.map(fn dp ->
        dp.date
      end)
      |> Enum.dedup()

    start_day_idx = get_start_day_idx(days)
    leaderboard = Contest.leaderboard(Enum.at(days, start_day_idx), @limit)

    user_position =
      Contest.leaderboard_position(
        Enum.at(days, start_day_idx),
        socket.assigns.current_user.attendee.id
      )

    {:ok,
     socket
     |> assign(:leaderboard, leaderboard)
     |> assign(:current_page, :leaderboard)
     |> assign(:user_position, user_position)
     |> assign(:current_day_str, display_current_day(days, start_day_idx))
     |> assign(:current_day_index, start_day_idx)
     |> assign(:days, days)
     |> assign(:left_enabled, start_day_idx > 0)
     |> assign(
       :right_enabled,
       start_day_idx < length(days) - 1 and not in_future(days, start_day_idx + 1)
     )
     |> assign(:daily_prizes, daily_prizes)
     |> assign(:prizes, get_day_prizes(daily_prizes, Enum.at(days, start_day_idx)))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("on_left", _, socket) do
    if socket.assigns.current_day_index > 0 do
      day = Enum.at(socket.assigns.days, socket.assigns.current_day_index - 1)

      {:noreply,
       socket
       |> assign(:current_day_index, socket.assigns.current_day_index - 1)
       |> assign(
         :current_day_str,
         display_current_day(socket.assigns.days, socket.assigns.current_day_index - 1)
       )
       |> assign(:left_enabled, socket.assigns.current_day_index > 1)
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
      day = Enum.at(socket.assigns.days, socket.assigns.current_day_index + 1)

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
         socket.assigns.current_day_index < length(socket.assigns.days) - 2 and
           not in_future(socket.assigns.days, socket.assigns.current_day_index + 2)
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

  defp get_start_day_idx(days) do
    today = Date.utc_today()

    idx = Enum.find_index(days, fn d -> d == today end)

    if is_nil(idx) do
      0
    else
      idx
    end
  end

  defp display_current_day(days, index) do
    days
    |> Enum.at(index)
    |> format_date()
  end

  defp in_future(days, index) do
    today = Date.utc_today()
    date = Enum.at(days, index)
    Date.diff(today, date) < 0
  end

  defp format_date(date) do
    today = Timex.today()
    yesterday = Timex.shift(today, days: -1)
    tomorrow = Timex.shift(today, days: 1)

    cond do
      Timex.equal?(date, today) ->
        gettext("Today")

      Timex.equal?(date, yesterday) ->
        gettext("Yesterday")

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
