defmodule SafiraWeb.Backoffice.StaffLive.Index do
  use SafiraWeb, :backoffice_view

  alias Phoenix.Socket.Broadcast
  alias Safira.Accounts
  alias SafiraWeb.Presence

  import SafiraWeb.Components.{Table, TableSearch}

  alias Safira.Accounts.User
  alias Safira.Repo
  alias Safira.Roles

  on_mount {SafiraWeb.StaffRoles,
            index: %{"staffs" => ["show"]},
            new: %{"staffs" => ["edit"]},
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
         |> assign(:staffs, staffs)
         |> apply_action(socket.assigns.live_action, params)}

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
    case Enum.find(diff, fn {_, %{metas: metas}} ->
           Enum.any?(metas, fn meta -> meta.id == staff.id end)
         end) do
      nil -> staff
      _ -> Map.put(staff, :is_online, value)
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Staffs")
  end

  defp apply_action(socket, :new, _params) do
    roles =
      Roles.list_roles()
      |> Enum.map(&{&1.name, &1.id})

    socket
    |> assign(:page_title, "New Staff")
    |> assign(:user, %User{})
    |> assign(:roles, roles)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    roles =
      Roles.list_roles()
      |> Enum.map(&{&1.name, &1.id})

    staff = Accounts.get_staff!(id) |> Repo.preload(:user)
    user = if staff.user, do: staff.user, else: %User{}

    socket
    |> assign(:page_title, "Edit Staff")
    |> assign(:user, user)
    |> assign(:roles, roles)
  end

  defp apply_action(socket, _live_action, _params) do
    socket
  end
end
