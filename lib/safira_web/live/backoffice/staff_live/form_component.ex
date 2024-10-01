defmodule SafiraWeb.Backoffice.StaffLive.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms
  alias Safira.Accounts
  alias Safira.Roles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <.simple_form
          for={@form}
          id="staff-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:role_id]} type="select" label="Role" options={@roles} required />
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Staff</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    roles =
      Roles.list_roles()
      |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:roles, roles)}
  end

  @impl true
  def update(%{id: id} = assigns, socket) do
    staff = Accounts.get_staff!(id)
    change_staff = Accounts.change_staff(staff, %{})
    form = to_form(change_staff, as: "staff")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:staff, staff)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"staff" => staff_params}, socket) do
    {:noreply,
     socket
     |> assign_new(:form, fn ->
       to_form(Accounts.change_staff(socket.assigns.staff, staff_params))
     end)}
  end

  def handle_event("save", %{"staff" => staff_params}, socket) do
    staff = socket.assigns.staff

    case Accounts.update_staff(staff, staff_params) do
      {:ok, _staff} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Staff updated successfully."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Something went wrong when updating the staff."))
         |> assign(:form, to_form(changeset))
         |> push_patch(to: socket.assigns.patch)}
    end
  end
end
