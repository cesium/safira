defmodule SafiraWeb.StaffRoles do
  @moduledoc false

  def on_mount(scope, _params, _session, socket) do
    user = socket.assigns.current_user
    live_action = socket.assigns.live_action

    permissions = user.staff.role.permissions |> Enum.into(%{})

    scopes = Keyword.get(scope, live_action)
    scope_key = Map.keys(scopes) |> List.first()
    scope_value = Map.get(scopes, scope_key)
    values = Map.get(permissions, scope_key, [])

    match = Enum.all?(scope_value, fn x -> Enum.member?(values, x) end)

    if match do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "You are not authorized to access this page.")
       |> Phoenix.LiveView.redirect(to: "/dashboard")}
    end
  end
end
