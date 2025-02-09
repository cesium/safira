defmodule SafiraWeb.Backoffice.ProfileSettingsLive do
  use SafiraWeb, :backoffice_view

  @impl true
  def render(assigns) do
    ~H"""
    <.page title="Profile Settings" subtitle="Manage your profile settings" size={:xl}>
      <.live_component
        module={SafiraWeb.UserAuth.Components.UserProfileSettings}
        id="attendee-user-profile-settings"
        user={@current_user}
      />
      <.live_component
        module={SafiraWeb.Components.CVUpload}
        id={@current_user.id || :new}
        current_user={@current_user}
        action={@live_action}
        patch={~p"/dashboard/profile_settings"}
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

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end
end
