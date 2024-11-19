defmodule SafiraWeb.Backoffice.SpotlightLive.Tiers.Show do
  use SafiraWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <.page title={@title}>
        <ul
          id="tiers"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-hook="Sorting"
          phx-update="stream"
        >
          <li
            :for={{_, tier} <- @streams.tiers}
            id={"tier-" <> tier.id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              <.icon name="hero-bars-3" class="w-5 h-5 handle cursor-pointer ml-4" />
              <%= tier.name %>
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
                <.link navigate={~p"/dashboard/spotlights/tiers/#{tier.id}/edit"}>
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
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

end
