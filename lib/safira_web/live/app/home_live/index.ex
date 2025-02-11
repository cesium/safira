defmodule SafiraWeb.App.HomeLive.Index do
  use SafiraWeb, :app_view

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

  defp apply_action(socket, :index, _) do
    socket
    |> assign(:page_title, "Profile")
  end

  defp apply_action(socket, :edit, _) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:attendee, socket.assigns.current_user.attendee)
  end
end
