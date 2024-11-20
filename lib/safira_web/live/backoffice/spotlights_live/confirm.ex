defmodule SafiraWeb.Backoffice.SpotlightLive.Confirm do
  use SafiraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="spotlight-new">
      <.page >
      <p class="text-center text-2xl mb-4">Are you sure?</p>
          <div class="flex justify-center space-x-8">
            <.button phx-click="confirm_yes" >Yes</.button>
            <.button phx-click="confirm_no" >No</.button>
          </div>
      </.page>
    </div>
    """
  end

  @impl true
  def handle_event("confirm_yes", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("confirm_no", _params, socket) do
    {:noreply, socket}
  end
end
