defmodule SafiraWeb.Components.EnsurePermissions do
  @moduledoc false
  use SafiraWeb, :component

  attr :user, :map, required: true, doc: "The current user."
  attr :permissions, :map, required: true, doc: "The permissions required to render the content."

  slot :inner_block,
    required: true,
    doc: "content that will only be shown when the staff has the required permissions."

  def ensure_permissions(assigns) do
    ~H"""
    <%= if verify_permissions(@user, @permissions) do %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end

  def verify_permissions(user, permissions) do
    user_permissions = user.staff.role.permissions

    scope_key = Map.keys(permissions) |> List.first()
    scope_value = Map.get(permissions, scope_key, [])

    values = Map.get(user_permissions, scope_key, [])

    Enum.all?(scope_value, fn x -> Enum.member?(values, x) end)
  end
end
