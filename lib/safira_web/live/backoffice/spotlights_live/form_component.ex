defmodule SafiraWeb.Backoffice.SpotlightLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Spotlights

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
      <:actions>
        <.link navigate={~p"/dashboard/spotlights/config/tiers"}>
            <.button>
              <.icon name="hero-rectangle-stack" class="w-5" />
            </.button>
          </.link>  
        </:actions>
        <div class="w-full space-y-2">
          <.simple_form for={@form} id="spotlight-form">
            <div>
              <.field field={@form[:duration]} type="number" label="Duration" required />
            </div>
            <.button phx-disable-with="Saving...">Save Configuration</.button>
          </.simple_form>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(
       form:
         to_form(
           %{"duration" =>Spotlights.get_spotlights_duration()},
           as: :spotlight_config
         )
     )}
  end

  @impl true
  def handle_event("save", params, socket) do
    Spotlights.change_duration_spotlight(params["duration"] |> String.to_integer())
      {:noreply, socket |> push_patch(to: ~p"/dashboard/spotlights/")}
      {:noreply, socket}
  end
end
