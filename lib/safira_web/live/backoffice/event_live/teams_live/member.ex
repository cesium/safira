defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.Members do
  use SafiraWeb, :live_component

  alias Safira.Teams
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Manage your team members here.")}>
        <.simple_form for={@form} id="member-form" phx-target={@myself} phx-submit="save">
          <div class="w-full space-y-2">
            <.field field={@form[:name]} name="member[name]" type="text" label="Member Name" required />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Add Team Member</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def update(%{member: member} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Teams.change_team_member(member))
     end)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(%{})
     end)}
  end

  @impl true
  def handle_event("save", %{"member" => member_params}, socket) do
    member_params = Map.put(member_params, "team_id", socket.assigns.team.id)
    save_member(socket, :members_new, member_params)
  end

  defp save_member(socket, :members_new, member_params) do
    case Teams.create_team_member(member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end

  defp save_member(socket, :teams_members, _member_params) do
    {:noreply,
     socket
     |> put_flash(:error, "Invalid action for saving a member.")
     |> push_patch(to: socket.assigns.patch)}
  end
end
