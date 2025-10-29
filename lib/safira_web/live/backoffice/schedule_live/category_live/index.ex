defmodule SafiraWeb.Backoffice.ScheduleLive.CategoryLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Activities

  import SafiraWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"schedule" => ["edit"]}}>
            <.link navigate={~p"/dashboard/schedule/activities/categories/new"}>
              <.button>New Category</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <ul
          id="categories"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-update="stream"
        >
          <li
            :for={{_, category} <- @streams.categories}
            id={"category-" <> category.id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              {category.name}
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
              <.ensure_permissions user={@current_user} permissions={%{"companies" => ["edit"]}}>
                <.link navigate={~p"/dashboard/schedule/activities/categories/#{category.id}/edit"}>
                  <.icon name="hero-pencil" class="w-5 h-5" />
                </.link>
                <.link
                  phx-click={
                    JS.push("delete", value: %{id: category.id})
                    |> hide("##{"category-" <> category.id}")
                  }
                  data-confirm="Are you sure?"
                  phx-target={@myself}
                >
                  <.icon name="hero-trash" class="w-5 h-5" />
                </.link>
              </.ensure_permissions>
            </p>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              {gettext("No activity categories found")}
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
     |> stream(:categories, Activities.list_activity_categories())}
  end
end
