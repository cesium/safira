defmodule SafiraWeb.Backoffice.SpotlightLive.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <div class="w-full space-y-2">
          <.field field={@form[:duration]} type="text" label="Duration" required />
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
