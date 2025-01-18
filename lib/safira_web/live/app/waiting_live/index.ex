defmodule SafiraWeb.App.WaitingLive.Index do
  use SafiraWeb, :app_view

  alias Safira.Event

  import SafiraWeb.Landing.Components.Sparkles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.sparkles/>
      <!-- 3D physics based credential scene  -->
      <div id="credential-scene" phx-hook="CredentialScene" data-attendee_name={@current_user.name} class="absolute -z-10 overflow-hidden top-0 left-0 w-screen h-full">
      </div>
      <!-- Timer to the event  -->
      <div class="z-20 mt-8">
        <h1 class="font-terminal text-center text-2xl sm:text-4xl uppercase"><%= gettext("Waiting for the event to start!") %></h1>
        <div
          id="seconds-remaining"
          class="font-terminal text-center text-4xl sm:text-6xl mt-12 uppercase"
          phx-hook="Countdown"
        >
        </div>
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
       |> assign(:event_started, false)
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
