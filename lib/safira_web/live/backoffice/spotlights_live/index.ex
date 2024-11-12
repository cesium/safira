defmodule SafiraWeb.Backoffice.SpotlightLive.Index do
  use SafiraWeb, :backoffice_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, show_form: false, title: "Spotlights")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :config, _params) do
    socket
    |> assign(:page_title, "Config")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Spotlights")
  end
end
