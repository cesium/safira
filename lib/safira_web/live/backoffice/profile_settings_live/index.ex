defmodule SafiraWeb.Backoffice.ProfileSettingsLive do
  use SafiraWeb, :backoffice_view

  def render(assigns) do
    assigns = assigns |> Map.put(:user, assigns.current_user)

    ~H"""
    <.page title="Profile Settings" subtitle="Manage your profile settings" size={:xl}>
      <.live_component
        module={SafiraWeb.UserAuth.Components.UserProfileSettings}
        id="attendee-user-profile-settings"
        user={@user}
      />
    </.page>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end
end
