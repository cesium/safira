defmodule SafiraWeb.Backoffice.ProfileSettingsLive do
  use SafiraWeb, :backoffice_view

  alias SafiraWeb.UserSettingsLive

  def mount(params, session, socket) do
    UserSettingsLive.mount(params, session, socket)
  end

  def handle_event(event, params, socket) do
    UserSettingsLive.handle_event(event, params, socket)
  end

  def render(assigns) do
    UserSettingsLive.render(assigns)
  end
end
