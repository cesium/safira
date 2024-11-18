defmodule SafiraWeb.Backoffice.SpotlightLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Spotlights

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <div class="w-full space-y-2">
          <.simple_form for={@form} id="spotlight-form">
            <div>
              <.field field={@form[:duration]} type="text" label="Duration" required />
            </div>
          </.simple_form>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
