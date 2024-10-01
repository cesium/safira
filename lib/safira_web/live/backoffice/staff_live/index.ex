defmodule SafiraWeb.Backoffice.StaffLive.Index do
  alias Safira.Accounts
  use SafiraWeb, :backoffice_view

  import SafiraWeb.Components.{Table, TableSearch}

  on_mount {SafiraWeb.StaffRoles,
            index: %{"staffs" => ["show"]},
            edit: %{"staffs" => ["edit"]},
            roles: %{"staffs" => ["roles_edit"]},
            roles_edit: %{"staffs" => ["roles_edit"]},
            roles_new: %{"staffs" => ["roles_edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_staffs(params, preloads: [:staff]) do
      {:ok, {staffs, meta}} ->
        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:current_page, :staffs)
         |> stream(:staffs, staffs, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
