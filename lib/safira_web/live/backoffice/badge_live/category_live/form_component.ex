defmodule SafiraWeb.BadgeLive.CategoryLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Contest
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext("Every badge gets assigned a category.") %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="w-full space-y-2">
          <.field field={@form[:name]} type="text" label="Name" required />
          <.field
            field={@form[:color]}
            type="select"
            options={colors_for_select()}
            label="Color"
            required
          />
          <.field
            field={@form[:hidden]}
            wrapper_class="pt-4"
            type="switch"
            label="Hidden"
            help_text={
              gettext(
                "Controls whether attendees can see badges with this category or if they are secret."
              )
            }
          />
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Category</.button>
        </:actions>
      </.simple_form>
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
       to_form(Contest.change_badge_category(category))
     end)}
  end

  @impl true
  def handle_event("validate", %{"badge_category" => category_params}, socket) do
    changeset = Contest.change_badge_category(socket.assigns.category, category_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"badge_category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :categories_edit, category_params) do
    case Contest.update_badge_category(socket.assigns.category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Badge category updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(socket, :categories_new, category_params) do
    case Contest.create_badge_category(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Badge category created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp colors_for_select do
    Enum.map(Contest.BadgeCategory.colors(), fn color ->
      {String.capitalize(color |> Atom.to_string()), color}
    end)
  end
end
