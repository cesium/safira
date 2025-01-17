defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.MembersEdit do
  use SafiraWeb, :live_component

  alias Safira.Teams
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <.simple_form for={@form} id="member-form" phx-target={@myself} phx-submit="save">
          <div class="w-full space-y-2">
            <.field field={@form[:name]} name="member[name]" type="text" label="Member Name" required />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Update Member</.button>
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
    IO.inspect(socket)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:member, fn ->
       Teams.get_team_member!(socket.assigns.member_id)
     end)
     |> assign_new(:form, fn ->
       to_form(Teams.change_team_member(%{}))
     end)}
  end

  @impl true
  def handle_event("save", %{"member" => member_params}, socket) do
    update_member(socket, :teams_members_edit, member_params)
  end

  defp update_member(socket, :teams_members_edit, member_params) do
    IO.inspect(member_params)
    IO.inspect(socket.assigns.member)

    case Teams.update_team_member(socket.assigns.member, member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end
end
