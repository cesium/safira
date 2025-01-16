defmodule SafiraWeb.Live.Backoffice.EventLive.TeamsLive.Members do
  use SafiraWeb, :live_component

  alias Safira.Teams
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("Manage your team members here.")}
      >
        <.simple_form
          for={@form}
          id="member-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2">
            <.field field={@form[:name]} type="text" label="Member Name" required />
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
  def handle_event("validate", %{"member" => member_params}, socket) do
    changeset = Teams.change_team_member(socket.assigns.member, member_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"member" => member_params}, socket) do
    save_member(socket, socket.assigns.action, member_params)
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

  defp save_member(socket, :members_edit, member_params) do
    case Teams.update_team_member(socket.assigns.member, member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
