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
     |> apply_action(socket.assigns.live_action)}
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:page_title, "Profile")
  end

  defp apply_action(socket, :edit) do
    socket
    |> assign(:page_title, "Edit Profile")
  end

  defp return_path(user) do
    case user.type do
      :attendee -> "app"
      :staff -> "dashboard"
      _ -> "app"
    end
  end
end
