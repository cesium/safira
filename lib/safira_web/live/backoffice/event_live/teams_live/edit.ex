defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.Edit do
  use SafiraWeb, :live_component

  alias Safira.Teams
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
      >
        <:actions>
        <.link navigate={~p"/dashboard/event/teams/#{@team.id}/edit/members"}>
            <.button>
              <.icon name="hero-adjustments-horizontal" />
            </.button>
          </.link>
        </:actions>
        <.simple_form
          for={@form}
          id="edit-team-form"
          phx-target={@myself}
          phx-submit="save"
        >
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:name]} type="text" label="Name" required />
            </div>
          </div>
          <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{id, members} <- @streams.members}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 px-4 py-4 flex flex-row w-full justify-between"
        >
            <p><%= members.name %></p>
            </li>
          </ul>
          <:actions>
            <.button phx-disable-with="Saving...">Save Team</.button>
          </:actions>
        </.simple_form>
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
    IO.inspect(assigns)
    {:ok,
     socket
     |> assign(assigns)
     |> stream(
       :members,
       Teams.list_team_members(assigns.team.id)
     )}
  end

end
