defmodule SafiraWeb.Backoffice.SpotlightLive.New do
  use SafiraWeb, :live_component

  alias Safira.Spotlights

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div id="spotlight-new">
      <.page title={@title}>
        <div>
          <.simple_form
            for={@form}
            id="company-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.field
              field={@form[:badge_id]}
              type="select"
              options={options(@badges)}
              label="Company"
              wrapper_class=""
              required
            />
          </.simple_form>
        </div>
        <.link patch={~p"/dashboard/spotlights/new/confirm"}>
          <.button phx-disable-with="Saving...">Save</.button>
        </.link>
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
           %{"company" => Spotlights.get_spotlights_duration()},
           as: :spotlight_config
         )
     )}
  end

  defp options(tiers) do
    Enum.map(tiers, &{&1.name, &1.id})
  end

  @impl true
  def handle_event("save", params, socket) do
    Spotlights.change_duration_spotlight(params["duration"] |> String.to_integer())
    {:noreply, socket |> push_patch(to: ~p"/dashboard/spotlights/new/confirm")}
    {:noreply, socket}
  end
end
