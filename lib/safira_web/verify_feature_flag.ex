defmodule SafiraWeb.VerifyFeatureFlag do
  @moduledoc false

  alias Safira.Event

  def on_mount(scope, _params, _session, socket) do
    enabled = Event.get_feature_flag!(scope)

    is_staff =
      not is_nil(socket.assigns.current_user) and
        socket.assigns.current_user.type == :staff

    if enabled or is_staff do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.redirect(to: "/")}
    end
  end
end
