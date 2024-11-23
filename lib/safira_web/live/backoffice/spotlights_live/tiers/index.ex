defmodule SafiraWeb.Backoffice.SpotlightLive.Tiers.Index do
  use SafiraWeb, :live_component

  alias Safira.Companies

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <ul id="tiers" class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{_, tier} <- @streams.tiers}
            id={"tier-" <> tier.id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              <%= tier.name %>
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
              <.link navigate={~p"/dashboard/spotlights/config/tiers/#{tier.id}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-4" />
              </.link>
            </p>
          </li>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:tiers, Companies.list_tiers())}
  end

  @impl true
  def handle_event("update-sorting", %{"ids" => ids}, socket) do
    ids
    |> Enum.with_index(0)
    |> Enum.each(fn {"tier-" <> id, index} ->
      id
      |> Companies.get_tier!()
      |> Companies.update_tier(%{priority: index})
    end)

    {:noreply, socket}
  end
end
