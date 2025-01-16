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
        <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{id, teams} <- @streams.teams}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 px-4 py-4 flex flex-row w-full justify-between"
          >
            <p><%= teams.name %></p>
            <.link navigate={~p"/dashboard/event/teams/#{teams.id}/edit"}>
              <.icon name="hero-pencil" class="w-5 h-5" />
            </.link>
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
    {:ok,
     socket
     |> stream(:teams, Teams.list_teams())}
  end


end
