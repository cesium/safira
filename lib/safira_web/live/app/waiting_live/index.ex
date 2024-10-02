defmodule SafiraWeb.App.WaitingLive.Index do
  use SafiraWeb, :live_view

  alias SafiraWeb.Helpers

  def render(assigns) do
    ~H"""
    <div>
      <h1>Countdown Timer</h1>
      <div id="seconds-remaining" phx-hook="Countdown"></div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    start_time = Helpers.get_start_time!()

    if DateTime.compare(start_time, DateTime.utc_now()) == :lt do
      {:ok,
       socket
       |> push_navigate(to: ~p"/app")}
    else
      {:ok,
       socket
       |> push_event("highlight", %{start_time: start_time})}
    end
  end
end
