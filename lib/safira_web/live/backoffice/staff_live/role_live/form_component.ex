defmodule SafiraWeb.Backoffice.StaffLive.RoleLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Roles
  import SafiraWeb.Components.Forms
  alias Safira.Accounts.Role
  alias Safira.Accounts.Roles.Permissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={
          gettext(
            "Roles are assigned to staff users and define the actions they are allowed to use in the application."
          )
        }
      >
        <.simple_form
          for={@form}
          id="roles-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2 text-dark dark:text-light">
            <div class="flex flex-row gap-2 items-center">
              <.field field={@form[:name]} type="text" />
            </div>
            <div>
              <.field
                field={@form[:permissions]}
                type="checkbox-group"
                options={@forms_permissions}
                checked={flatten_permissions(Map.get(@form.data, :permissions, []))}
                multiple
                class="border border-2 rounded-xl px-2 h-32 overflow-y-scroll"
                group_layout="col"
              />
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Role</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    permissions = Permissions.all()

    forms_permissions =
      permissions
      |> Enum.map(fn {category, permissions} ->
        {category, Enum.map(permissions, fn permission -> ["#{category}-#{permission}"] end)}
      end)

    {:ok,
     socket
     |> assign(:permissions, permissions)
     |> assign(:forms_permissions, forms_permissions)}
  end

  @impl true
  def update(%{id: "new-role"} = assigns, socket) do
    form = to_form(%{}, as: "roles")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:role, %Role{})
     |> assign(:form, form)}
  end

  @impl true
  def update(%{id: id} = assigns, socket) do
    role = Roles.get_role!(id)
    change_role = Roles.change_role(role, %{})
    form = to_form(change_role, as: "roles")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:role, role)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"roles" => values}, socket) do
    {:noreply,
     socket
     |> assign_new(:form, fn ->
       to_form(Roles.change_role(socket.assigns.role, values))
     end)}
  end

  def handle_event(
        "save",
        %{"roles" => %{"name" => name, "permissions" => selected_permissions}} = _assigns,
        socket
      ) do
    permissions =
      selected_permissions
      |> Enum.map(fn x -> String.split(x, "-") end)
      |> Enum.group_by(fn [category, _permission] -> category end)
      |> Enum.map(fn {category, permissions} ->
        {category, Enum.map(permissions, fn [_, permission] -> permission end)}
      end)
      |> Enum.into(%{})

    role_params = %{name: name, permissions: permissions}

    save_role(socket, socket.assigns.action, role_params)
  end

  def save_role(socket, :roles_edit, role_params) do
    case Roles.update_role(socket.assigns.role, role_params) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Role updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Error updating role."))
         |> assign(:form, to_form(changeset))}
    end
  end

  def save_role(socket, :roles_new, role_params) do
    case Roles.create_role(role_params) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Role created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Error creating role."))
         |> assign(:form, to_form(changeset))}
    end
  end

  defp flatten_permissions(permissions) do
    permissions
    |> Enum.flat_map(fn {role, perms} ->
      Enum.map(perms, fn perm -> "#{role}-#{perm}" end)
    end)
  end
end
