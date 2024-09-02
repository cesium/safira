defmodule SafiraWeb.BadgeLive.ConditionLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext("Defined conditions allow this badge to be awarded automatically.") %>
        </:subtitle>
        <:actions>
          <.link navigate={~p"/dashboard/badges/#{@badge.id}/conditions/new"}>
            <.button>New Condition</.button>
          </.link>
        </:actions>
      </.header>
      <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
        <li
          :for={{_, condition} <- @streams.conditions}
          class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4"
        >
          <p class="text-dark dark:text-light flex flex-row justify-between">
            <%= condition_description(condition) %>
            <.link navigate={~p"/dashboard/badges/#{@badge.id}/conditions/#{condition.id}/edit"}>
              <.icon name="hero-pencil" class="w-5 h-5" />
            </.link>
          </p>
        </li>
        <div class="only:flex hidden h-full items-center justify-center">
          <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
            <%= gettext("No conditions set for this badge.") %>
          </p>
        </div>
      </ul>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> stream(
       :conditions,
       Contest.list_badge_conditions(assigns.badge.id, preloads: [:category])
     )}
  end

  def condition_description(condition) do
    if condition.category_id do
      gettext("When receiving a badge of type %{category_name}.",
        category_name: condition.category.name
      )
    else
      gettext("When receiving any badge.")
    end
  end
end
