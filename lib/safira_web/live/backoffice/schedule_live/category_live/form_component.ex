defmodule SafiraWeb.Backoffice.ScheduleLive.CategoryLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Activities
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Categories group scheduled activities.")}>
        <.simple_form
          for={@form}
          id="category-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full">
            <.field field={@form[:name]} type="text" label="Name" required />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Category</.button>
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
  def update(%{category: category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity_category(category))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activity_category" => category_params}, socket) do
    changeset = Activities.change_activity_category(socket.assigns.category, category_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity_category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :categories_edit, category_params) do
    case Activities.update_activity_category(socket.assigns.category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity category updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(socket, :categories_new, category_params) do
    case Activities.create_activity_category(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity category created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
