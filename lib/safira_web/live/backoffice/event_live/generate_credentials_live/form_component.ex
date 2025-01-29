defmodule SafiraWeb.Backoffice.EventLive.GenerateCredentialsLive.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Generate Credentials")}>
        <.simple_form for={@form} id="faq-form" phx-target={@myself} action={~p"/downloads/qr_codes"}>
          <div class="w-full space-y-2">
            <.field field={@form[:count]} type="number" label="Number of Credentials" required />
          </div>
          <:actions>
            <.button phx-disable-with="Generating...">Generate</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(%{count: 0})
     end)}
  end
end
