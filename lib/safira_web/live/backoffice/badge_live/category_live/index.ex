defmodule SafiraWeb.Backoffice.BadgeLive.CategoryLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.link navigate={~p"/dashboard/badges/categories/new"}>
            <.button>New Category</.button>
          </.link>
        </:actions>
        <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{_, category} <- @streams.categories}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4"
          >
            <p class="text-dark dark:text-light flex flex-row justify-between">
              <span class="flex gap-2">
                <span
                  aria-hidden="true"
                  class={"h-6 w-6 block #{get_color_class(category.color)} rounded-full"}
                >
                </span>
                <%= category.name %>
              </span>
              <.link navigate={~p"/dashboard/badges/categories/#{category.id}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
            </p>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              <%= gettext("No categories found") %>
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
     |> stream(:categories, Contest.list_badge_categories())}
  end

  def get_color_class(color) do
    case color do
      :gray -> "bg-gray-500"
      :red -> "bg-red-500"
      :orange -> "bg-orange-500"
      :amber -> "bg-amber-500"
      :yellow -> "bg-yellow-500"
      :lime -> "bg-lime-500"
      :green -> "bg-green-500"
      :emerald -> "bg-emerald-500"
      :teal -> "bg-teal-500"
      :cyan -> "bg-cyan-500"
      :sky -> "bg-sky-500"
      :blue -> "bg-blue-500"
      :indigo -> "bg-indigo-500"
      :violet -> "bg-violet-500"
      :purple -> "bg-purple-500"
      :fuchsia -> "bg-fuchsia-500"
      :pink -> "bg-pink-500"
      :rose -> "bg-rose-500"
    end
  end
end
