defmodule SafiraWeb.Backoffice.ScheduleLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Activities
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Activities that happen troughout the event.")}>
        <.simple_form
          for={@form}
          id="activity-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full">
            <div class="w-full flex gap-2">
              <.field field={@form[:title]} type="text" label="Title" required wrapper_class="w-full" />
              <.field field={@form[:location]} type="text" label="Location" wrapper_class="w-full" />
            </div>
            <.field field={@form[:description]} type="textarea" label="Description" />
            <div class="w-full grid grid-cols-4 gap-2">
              <.field
                field={@form[:date]}
                type="date"
                label="Date"
                required
                wrapper_class="col-span-2"
              />
              <.field
                field={@form[:time_start]}
                type="time"
                label="Start"
                required
                wrapper_class="col-span-1"
              />
              <.field
                field={@form[:time_end]}
                type="time"
                label="End"
                required
                wrapper_class="col-span-1"
              />
            </div>
            <div class="w-full flex gap-2">
              <.field
                field={@form[:category_id]}
                type="select"
                label="Category"
                options={categories_options(@categories)}
                wrapper_class="w-full"
              />
              <.field
                field={@form[:has_enrolments]}
                type="checkbox"
                label="Requires enrolment"
                wrapper_class="w-full"
              />
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Activity</.button>
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
  def update(%{activity: activity} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity(activity))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset = Activities.change_activity(socket.assigns.activity, activity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity" => activity_params}, socket) do
    save_activity(socket, socket.assigns.action, activity_params)
  end

  defp save_activity(socket, :edit, activity_params) do
    case Activities.update_activity(socket.assigns.activity, activity_params) do
      {:ok, _activity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activity(socket, :new, activity_params) do
    case Activities.create_activity(activity_params) do
      {:ok, _activity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp categories_options(categories) do
    [{"None", nil}] ++
      Enum.map(categories, &{&1.name, &1.id})
  end
end
