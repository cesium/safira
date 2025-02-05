defmodule SafiraWeb.Backoffice.StaffLive.Index do
  use SafiraWeb, :backoffice_view

  alias Phoenix.Socket.Broadcast
  alias Safira.Accounts
  alias SafiraWeb.Presence

  import SafiraWeb.Components.{Table, TableSearch}

  on_mount {SafiraWeb.StaffRoles,
            index: %{"staffs" => ["show"]},
            edit: %{"staffs" => ["edit"]},
            roles: %{"staffs" => ["roles_edit"]},
            roles_edit: %{"staffs" => ["roles_edit"]},
            roles_new: %{"staffs" => ["roles_edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Presence.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_staffs(params, preloads: [:staff]) do
      {:ok, {staffs, meta}} ->
        presences = Presence.list_presences()
        staffs = Enum.map(staffs, &build_staff_presence(&1, presences))

        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:current_page, :staffs)
         |> assign(:staffs, staffs)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: payload}, socket) do
    apply_presence_diff(socket, payload[:joins], payload[:leaves])
  end

  defp apply_presence_diff(socket, joins, leaves) when map_size(leaves) == 0 do
    staffs = Enum.map(socket.assigns.staffs, &maybe_update_staff_presence(&1, joins, true))
    {:noreply, assign(socket, :staffs, staffs)}
  end

  defp apply_presence_diff(socket, joins, leaves) when map_size(joins) == 0 do
    staffs = Enum.map(socket.assigns.staffs, &maybe_update_staff_presence(&1, leaves, false))
    {:noreply, assign(socket, :staffs, staffs)}
  end

  defp build_staff_presence(staff, presences) do
    keys = Map.keys(presences)

    staff
    |> Map.put(:is_online, Enum.member?(keys, staff.id))
  end

  defp maybe_update_staff_presence(staff, diff, value) do
    case Enum.find(diff, fn {_, %{metas: [data]}} -> data.id == staff.id end) do
      nil -> staff
      _ -> Map.put(staff, :is_online, value)
    end
  end
end
