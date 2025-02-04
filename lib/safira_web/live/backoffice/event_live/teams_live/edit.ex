defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.Edit do
  use SafiraWeb, :live_component

  alias Safira.Teams
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.link :if={@action != :teams_new} navigate={~p"/dashboard/event/teams/#{@team.id}/edit/members"}>
            <.button>
              <.icon name="hero-users" />
            </.button>
          </.link>
        </:actions>
        <.simple_form for={@form} id="edit-team-form" phx-target={@myself} phx-submit="save">
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:name]} name="team[name]" type="text"/>
            </div>
          </div>
          <ul id="members" :if={@action != :teams_new} class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto" phx-update="stream">
            <li
              :for={{id, member} <- @streams.members}
              id={id}
              class="even:bg-lightShade/20 dark:even:bg-darkShade/20 px-4 py-4 flex flex-row w-full justify-between"
            >
              <p><%= member.name %></p>
              <div>
              <.link navigate={~p"/dashboard/event/teams/#{@team.id}/edit/members/#{member.id}"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
              <.link
              phx-click={JS.push("delete", value: %{id: member.id})}
              data-confirm="Are you sure?"
              phx-target={@myself}
            >
              <.icon name="hero-trash" class="w-5 h-5" />
            </.link>
            </div>
            </li>
            <div class="hidden only:flex flex-col gap-4 items-center w-full justify-center h-full">
              <.icon name="hero-user" class="w-12 h-12" />
              <p><%= gettext("No members found.") %></p>
            </div>
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
  def update(%{team: team} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Teams.change_team(team))
     end)
     |> stream(
       :members,
       case Teams.list_team_members(assigns.team.id) do
         {:ok, members} -> members
         _ -> []
       end
     )}
  end

  @impl true
  def handle_event("save", %{"team" => team_params}, socket) do
    save_team(socket, socket.assigns.action, team_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member = Teams.get_team_member!(id)

    case Teams.delete_team_member(member) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member deleted successfully")
         |> stream_delete(:members, member)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete member")}
    end
  end

  defp save_team(socket, :teams_update, team_params) do
    case Teams.update_team(socket.assigns.team, team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end

  defp save_team(socket, :teams_new, team_params) do
    case Teams.create_team(
           team_params
           |> Map.put("priority", Teams.get_next_team_priority())
         ) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end
end
