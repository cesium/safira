defmodule SafiraWeb.Backoffice.SpotlightLive.Index do
  use Phoenix.LiveView
  use SafiraWeb, :backoffice_view

  alias Safira.{Companies, Contest}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect(socket.assigns.live_action)

    {:noreply,
     socket
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
    |> assign(:spotlight_id, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Spotlights")
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
    |> assign(:page_title, "Create Spotligth")
    |> assign(:badges, Contest.list_badges())
  end
end
