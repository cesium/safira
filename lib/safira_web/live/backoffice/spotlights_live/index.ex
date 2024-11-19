defmodule SafiraWeb.Backoffice.SpotlightLive.Index do
  use Phoenix.LiveView
  use SafiraWeb, :backoffice_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
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

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Edit Spotlights bonus multiplior")
  end
end
