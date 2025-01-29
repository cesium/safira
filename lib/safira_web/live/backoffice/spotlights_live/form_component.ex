defmodule SafiraWeb.Backoffice.SpotlightLive.FormComponent do
  @moduledoc """
  A LiveComponent for managing the spotlight configuration in the backoffice.
  """
  use SafiraWeb, :live_component

  alias Safira.Spotlights

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.flash_group flash={@flash} />
      <.page title={@title}>
        <:actions>
          <.link navigate={~p"/dashboard/spotlights/config/tiers"}>
            <.button>
              <.icon name="hero-rectangle-stack" class="w-5" />
            </.button>
          </.link>
        </:actions>
        <div class="w-full space-y-2">
          <.simple_form for={@form} id="spotlight-form" phx-submit="save" phx-target={@myself}>
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
    duration = Spotlights.get_spotlight_duration() || 0
    form = to_form(%{"duration" => duration}, as: :spotlight_config)

    {:ok, socket |> assign(form: form)}
  end

  @impl true
  def handle_event("save", %{"spotlight_config" => %{"duration" => duration}}, socket) do
    case Spotlights.change_spotlight_duration(String.to_integer(duration)) do
      {:ok, _} ->
        {:noreply, push_patch(socket, to: ~p"/dashboard/spotlights/")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Duration can't be more than 60 minutes")}
    end
  end
end
