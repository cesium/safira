defmodule SafiraWeb.Backoffice.ScheduleLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Activities
  alias Safira.Activities.Speaker
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
            <div class="flex gap-2">
              <.field
                field={@form[:category_id]}
                type="select"
                label="Category"
                options={categories_options(@categories)}
                wrapper_class="w-full"
              />
              <.field_multiselect
                field={@form[:speakers]}
                target={@myself}
                value_mapper={&value_mapper/1}
                wrapper_class="w-full"
                placeholder={gettext("Search for speakers")}
              />
            </div>
            <div class="w-full flex gap-2">
              <div class="w-full grid grid-cols-2">
                <div class="w-full flex flex-col">
                  <.label>
                    <%= gettext("Enrolments") %>
                  </.label>
                  <p class="safira-form-help-text">
                    <%= gettext(
                      "Enable enrolments to allow participants to sign up for this activity."
                    ) %>
                  </p>
                  <.field
                    field={@form[:has_enrolments]}
                    type="switch"
                    label=""
                    wrapper_class="w-full pt-3"
                  />
                </div>
                <.field
                  :if={@enrolments_active}
                  field={@form[:max_enrolments]}
                  type="number"
                  label="Max enrolments"
                  wrapper_class="w-full"
                />
              </div>
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
     |> assign(:enrolments_active, activity.has_enrolments)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity(activity))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset = Activities.change_activity(socket.assigns.activity, activity_params)

    {:noreply,
     assign(socket,
       form: to_form(changeset, action: :validate),
       enrolments_active: activity_params["has_enrolments"] != "false"
     )}
  end

  def handle_event("save", %{"activity" => activity_params}, socket) do
    save_activity(socket, socket.assigns.action, activity_params)
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    case Activities.list_speakers(%{
           "filters" => %{"1" => %{"field" => "name", "op" => "ilike_or", "value" => text}}
         }) do
      {:ok, {speakers, _meta}} ->
        send_update(LiveSelect.Component,
          id: live_select_id,
          options: speakers |> Enum.map(&{&1.name, &1.id})
        )

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp save_activity(socket, :edit, activity_params) do
    case Activities.update_activity(socket.assigns.activity, activity_params) do
      {:ok, _activity} ->
        case Activities.upsert_activity_speakers(
               socket.assigns.activity,
               activity_params["speakers"]
             ) do
          {:ok, _activity} ->
            {:noreply,
             socket
             |> put_flash(:info, "Activity updated successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activity(socket, :new, activity_params) do
    case Activities.create_activity(activity_params) do
      {:ok, activity} ->
        case Activities.upsert_activity_speakers(
               Map.put(activity, :speakers, []),
               activity_params["speakers"]
             ) do
          {:ok, _activity} ->
            {:noreply,
             socket
             |> put_flash(:info, "Activity created successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp categories_options(categories) do
    [{"None", nil}] ++
      Enum.map(categories, &{&1.name, &1.id})
  end

  defp value_mapper(%Speaker{} = speaker), do: {speaker.name, speaker.id}

  defp value_mapper(id), do: id
end
