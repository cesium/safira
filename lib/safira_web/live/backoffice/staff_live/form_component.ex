defmodule SafiraWeb.Backoffice.StaffLive.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms
  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Repo

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
              <.field field={@form[:name]} type="text" label="Name" required />
              <.field field={@form[:email]} type="email" label="Email" required />
              <.field
                field={@form[:password]}
                type="password"
                label="Password"
                value={@generated_password}
                required
              />
              <.field field={@form[:handle]} type="text" label="Handle" required />
              <.inputs_for :let={att} field={@form[:staff]}>
                <.field field={att[:role_id]} type="select" label="Role" options={@roles} required />
              </.inputs_for>
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
    {:ok, socket}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    user = user |> Repo.preload(:staff)
    user_changeset = Accounts.change_user_registration(user)

    password =
      :crypto.strong_rand_bytes(12)
      |> Base.encode64()
      |> binary_part(0, 12)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:generated_password, password)
     |> assign(:form, to_form(user_changeset))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do

    changeset =
      Accounts.change_user_registration(%User{}, user_params) |> IO.inspect()

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_staff(socket, socket.assigns.action, user_params)
  end

  defp save_staff(socket, :new, user_params) do
    case Accounts.register_staff_user(user_params) do
      {:ok, _staff} ->
        {:noreply,
         socket
         |> put_flash(:info, "Staff created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _, %Ecto.Changeset{} = changeset, _} ->
        IO.inspect(changeset)

        {:noreply,
         socket
         |> put_flash(:error, gettext("Something went wrong while creating the staff."))
         |> assign(:form, to_form(changeset, action: :validate))}
    end
  end

  defp save_staff(socket, :edit, user_params) do
    user = socket.assigns.user |> Repo.preload(:staff)
    user_params = user_params |> Map.delete("password")
    IO.inspect(user, label: "user")
    IO.inspect(user_params)

    case Accounts.update_user(user, user_params) do
      {:ok, _staff} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Staff updated successfully."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Something went wrong when updating the staff."))
         |> assign(:form, to_form(changeset))}
    end
  end
end
