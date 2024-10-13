defmodule SafiraWeb.Backoffice.StaffLive.RoleLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Roles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.link navigate={~p"/dashboard/staffs/roles/new"}>
            <.button><%= gettext("New Role") %></.button>
          </.link>
        </:actions>
        <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{id, role} <- @streams.roles}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4"
            id={id}
            phx-update="stream"
          >
            <p class="text-dark dark:text-light flex flex-row justify-between">
              <%= role.name %>
              <.link navigate={~p"/dashboard/staffs/roles/#{role.id}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
            </p>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              <%= gettext("No roles found") %>
            </p>
          </div>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:roles, Roles.list_roles())}
  end
end
