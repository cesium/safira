defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Teams

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.link navigate={~p"/dashboard/event/teams/new"}>
            <.button>New Team</.button>
          </.link>
        </:actions>
        <ul
          id="teams"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-hook="Sorting"
          phx-update="stream"
        >
          <li
            :for={{id, team} <- @streams.teams}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 px-4 py-4 flex flex-row w-full justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              <.icon name="hero-bars-3" class="w-5 h-5 handle cursor-pointer ml-4" />
              <p><%= team.name %></p>
            </div>
            <div>
            <.link navigate={~p"/dashboard/event/teams/#{team.id}/edit/"}>
              <.icon name="hero-pencil" class="w-5 h-5" />
            </.link>
            <.link
              phx-click={JS.push("delete", value: %{id: team.id})}
              data-confirm="Are you sure?"
              phx-target={@myself}
            >
              <.icon name="hero-trash" class="w-5 h-5" />
            </.link>
            </div>
          </li>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> stream(:teams, Teams.list_teams(preloads: [:team_members]))}
  end

  @impl true
  def handle_event("update-sorting", %{"ids" => ids}, socket) do
    ids
    |> Enum.with_index(0)
    |> Enum.each(fn {id, index} ->
      id
      |> Teams.get_team!()
      |> Teams.update_team(%{priority: index})
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team!(id)

    case Teams.delete_team(team) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team deleted successfully")
         |> stream_delete(:teams, team)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete team")}
    end
  end
end
