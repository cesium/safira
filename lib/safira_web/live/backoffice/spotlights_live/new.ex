defmodule SafiraWeb.Backoffice.SpotlightLive.New do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div id="spotlight-new">
      <.page title={@title}>
        <div>
          <.simple_form for={@form} id="company-form" phx-target={@myself} phx-submit="save">
            <.field
              field={@form[:company_id]}
              type="select"
              options={options(@companies)}
              label="Company"
              wrapper_class=""
              required
            />
            <.button phx-disable-with="Saving...">Save</.button>
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
           %{"company_id" => ""},
           as: :company_form
         )
     )}
  end

  defp options(companies) do
    Enum.map(companies, &{&1.name, &1.id})
  end

  @impl true
  def handle_event("save", %{"company_form" => params}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/dashboard/spotlights/new/#{params["company_id"]}")}
  end
end
