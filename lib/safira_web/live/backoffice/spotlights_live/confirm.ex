defmodule SafiraWeb.Backoffice.SpotlightLive.Confirm do
  use SafiraWeb, :live_component

  import Safira.Companies
  alias Safira.Spotlights

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page>
        <div class="flex flex-col">
          <p class="text-center text-2xl mb-4">Are you sure?</p>
          <p class="text-center pb-6">
            <%= gettext(
              "Are you sure you want to start a spotlight for %{company_name} with a duration of %{duration} %{unit}?",
              company_name: @company.name,
              duration: @duration,
              unit: ngettext("minute", "minutes", @duration)
            ) %>
          </p>
          <div class="flex justify-center space-x-8">
            <.button phx-click="cancel-spotlight" class="w-full" phx-target={@myself} type="button">
              Cancel
            </.button>
            <.button phx-click="confirm-spotlight" class="w-full" phx-target={@myself} type="button">
              Start Spotlight
            </.button>
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def handle_event("confirm-spotlight", _params, socket) do
    if socket.assigns.company && socket.assigns.duration &&
         can_create_spotlight?(socket.assigns.company.id) do
      case Spotlights.create_spotlight(socket.assigns.company.id) do
        {:ok, _spotlight} ->
          {:noreply,
           socket
           |> put_flash(:info, "Spotlight started successfully.")
           |> push_navigate(to: ~p"/dashboard/spotlights")}

        {:error, msg} ->
          {:noreply,
           socket
           |> put_flash(:error, msg)
           |> push_patch(to: ~p"/dashboard/spotlights")}
      end
    else
      {:noreply, socket |> put_flash(:error, "Missing company or duration information.")}
    end
  end

  @impl true
  def handle_event("cancel-spotlight", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/dashboard/spotlights")}
  end
end
