defmodule SafiraWeb.App.WaitingLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Event

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <img class="w-52 h-52 m-auto block" src={~p"/images/sei.svg"} />
      <h1 class="font-terminal uppercase text-4xl sm:text-6xl text-center mt-24">
        You are registered for SEI'25!
      </h1>
      <h2 class="font-terminal text-xl sm:text-2xl text-center mt-4">We are almost ready</h2>
      <div
        id="seconds-remaining"
        class="font-terminal text-center text-2xl sm:text-4xl mt-12"
        phx-hook="Countdown"
      >
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if Event.event_started?() do
      {:ok,
       socket
       |> push_navigate(to: ~p"/app")}
    else
      if connected?(socket) do
        Event.subscribe_to_start_time_update("start_time")
      end

      {:ok,
       socket
       |> push_event("highlight", %{start_time: Event.get_event_start_time!()})}
    end
  end

  @impl true
  def handle_info({"start_time", value}, socket) do
    {:noreply,
     socket
     |> push_event("highlight", %{start_time: value})}
  end
end
