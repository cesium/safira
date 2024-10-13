defmodule SafiraWeb.Backoffice.CompanyLive.TierLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Companies
  import SafiraWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"companies" => ["edit"]}}>
            <.link navigate={~p"/dashboard/companies/tiers/new"}>
              <.button>New Tier</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
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
              <.ensure_permissions user={@current_user} permissions={%{"companies" => ["edit"]}}>
                <.link navigate={~p"/dashboard/companies/tiers/#{tier.id}/edit"}>
                  <.icon name="hero-pencil" class="w-5 h-4" />
                </.link>
                <.link
                  phx-click={
                    JS.push("delete", value: %{id: tier.id}) |> hide("##{"tier-" <> tier.id}")
                  }
                  data-confirm="Are you sure?"
                  phx-target={@myself}
                >
                  <.icon name="hero-trash" class="w-5 h-5" />
                </.link>
              </.ensure_permissions>
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tier = Companies.get_tier!(id)

    {:ok, _} = Companies.delete_tier(tier)

    {:noreply, stream_delete(socket, :tiers, tier)}
  end
end
