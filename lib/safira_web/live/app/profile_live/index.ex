defmodule SafiraWeb.App.ProfileLive.Index do
  use SafiraWeb, :app_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply,
     socket
     |> assign(:user, socket.assigns.current_user)
     |> assign(:current_page, :profile)
     |> apply_action(socket.assigns.live_action, _params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Profile")
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Profile")
  end
end
