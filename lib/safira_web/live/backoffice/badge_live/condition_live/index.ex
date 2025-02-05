defmodule SafiraWeb.Backoffice.BadgeLive.ConditionLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("Defined conditions allow this badge to be awarded automatically.")}
      >
        <:actions>
          <.link navigate={~p"/dashboard/badges/#{@badge.id}/conditions/new"}>
            <.button>New Condition</.button>
          </.link>
        </:actions>

        <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{id, condition} <- @streams.conditions}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between items-center"
          >
            <p class="text-dark dark:text-light flex flex-row justify-between">
              <%= condition_description(condition) %>
            </p>
            <div class="flex flex-row gap-2">
              <.link navigate={~p"/dashboard/badges/#{@badge.id}/conditions/#{condition.id}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
              <.link
                phx-click={JS.push("delete", value: %{id: condition.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
              >
                <.icon name="hero-trash" class="w-5 h-5" />
              </.link>
            </div>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              <%= gettext("No conditions set for this badge.") %>
            </p>
          </div>
        </ul>
      </.page>
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    condition = Contest.get_badge_condition!(id)

    {:ok, _} = Contest.delete_condition(condition)

    {:noreply, stream_delete(socket, :conditions, condition)}
  end

  def condition_description(condition) do
    if condition.category_id do
      if is_nil(condition.amount_needed) do
        gettext(
          "Attendee has redeemed all badges of type %{category_name}.",
          category_name: condition.category.name
        )
      else
        gettext(
          "Attendee has redeemed %{amount_needed} %{badge_cardinality} of type %{category_name}.",
          amount_needed: condition.amount_needed,
          category_name: condition.category.name,
          badge_cardinality: ngettext("badge", "badges", condition.amount_needed)
        )
      end
    else
      if is_nil(condition.amount_needed) do
        gettext("Attendee has redeemed all badges in the platform.")
      else
        gettext("Attendee has redeemed %{amount_needed} %{badge_cardinality} of any type.",
          amount_needed: condition.amount_needed,
          badge_cardinality: ngettext("badge", "badges", condition.amount_needed)
        )
      end
    end <>
      if condition.begin && condition.end do
        gettext(" (from %{begin} to %{end})",
          begin: Timex.format!(condition.begin, "{0D}/{0M}/{YYYY} {h24}:{m}"),
          end: Timex.format!(condition.end, "{0D}/{0M}/{YYYY} {h24}:{m}")
        )
      else
        gettext(" (available throughout the event's duration)")
      end
  end
end
