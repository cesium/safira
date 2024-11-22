defmodule SafiraWeb.Backoffice.SpotlightLive.Confirm do
  use SafiraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="spotlight-new">
      <.page>
        <div class="flex flex-col">
          <p class="text-center text-2xl mb-4">Are you sure?</p>
          <p class="text-center pb-6">
            Are you sure you want to start a spotlight for <%= @company.name %>.
          </p>
          <div class="flex justify-center space-x-8">
            <.button phx-click="cancel" class="w-full">Cancel</.button>
            <.button phx-click="confirm" class="w-full">Start Spotlight</.button>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def handle_event("confirm", _params, socket) do
    {:noreply, socket}
  end

  @impl true  
  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/dashboard/spotlights")}
  end
end
