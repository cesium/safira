defmodule SafiraWeb.Backoffice.SpotlightLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Companies
  alias Safira.Spotlights

  @impl true
  def mount(_params, _session, socket) do
    case Spotlights.get_current_spotlight() do
      nil ->
        {:ok, socket |> assign(:current_spotlight, nil)}

      spotlight ->
        {:ok,
         socket
         |> assign(:current_spotlight, spotlight)
         |> push_event("start-countdown", %{end_time: spotlight.end})}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:current_page, :spotlights)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :config, %{"id" => id}) do
    socket
    |> assign(:page_title, "Spotlights Config")
    |> assign(:spotlight_id, id)
  end

  defp apply_action(socket, :config, _params) do
    socket
    |> assign(:page_title, "Spotlights Config")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Spotlights Config")
    |> assign(:spotlight_id, nil)
  end

  defp apply_action(socket, :tiers, _params) do
    socket
    |> assign(:page_title, "Edit Spotlights bonus multiplier")
  end

  defp apply_action(socket, :tiers_edit, %{"id" => id}) do
    tier = Companies.get_tier!(id)

    socket
    |> assign(:page_title, "Edit Spotlights bonus multiplier for #{tier.name}")
    |> assign(:tier, tier)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create Spotlight")
    |> assign(:companies, Companies.list_companies())
  end

  defp apply_action(socket, :confirm, %{"id" => company_id}) do
    duration = Safira.Spotlights.get_spotlight_duration()

    socket
    |> assign(:page_title, "Confirm Spotlight")
    |> assign(:company, Companies.get_company!(company_id))
    |> assign(:duration, duration)
  end
end
