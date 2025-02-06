defmodule SafiraWeb.App.ProfileSettingsLive do
  use SafiraWeb, :app_view

  @impl true
  def render(assigns) do
    ~H"""
    <.page title="Profile Settings" subtitle="Manage your profile settings" size={:xl}>
      <.live_component
        module={SafiraWeb.UserAuth.Components.UserProfileSettings}
        id="attendee-user-profile-settings"
        user={@current_user}
      />
    </.page>
    """
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info({:update_current_user, new_user}, socket) do
    {:noreply, assign(socket, current_user: new_user)}
  end
end
