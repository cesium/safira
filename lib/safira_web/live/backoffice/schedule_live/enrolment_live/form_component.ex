defmodule SafiraWeb.Backoffice.ScheduleLive.EnrolmentLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Activities

  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={@activity.title}>
        <div class="pt-4 flex flex-col gap-2 h-[30.5rem]">
          <.simple_form
            id="enrolments-form"
            for={@form}
            phx-target={@myself}
            phx-validate="validate"
            phx-submit="save"
          >
            <.field
              field={@form[:activity_id]}
              type="hidden"
              value={@activity.id}
              required
            />
            <.field_multiselect
              mode={:single}
              id="attendee"
              field={@form[:attendee_id]}
              target={@myself}
              value_mapper={&value_mapper/1}
              wrapper_class="w-full"
              placeholder={gettext("Search for attendees")}
            />
            <.button phx-disable-with="Saving...">Save</.button>
          </.simple_form>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{enrolment: enrolment} = assigns, socket) do
    changeset = Activities.change_enrolment(enrolment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    case Accounts.list_attendees(%{
           "filters" => %{"1" => %{"field" => "name", "op" => "ilike_or", "value" => text}}
         }) do
      {:ok, {attendees, _meta}} ->
        send_update(LiveSelect.Component,
          id: live_select_id,
          options: attendees |> Enum.map(&{&1.name, &1.attendee.id})
        )

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"enrolment" => %{"activity_id" => activity_id, "attendee_id" => attendee_id}},
        socket
      ) do
    case Activities.enrol(attendee_id, activity_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Enrolled successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _, _, _} ->
        {:noreply, socket |> put_flash(:error, "Unable to enrol")}
    end
  end

  @impl true
  def handle_event("validate", %{"enrolment" => enrolment_params}, socket) do
    changeset = Activities.change_enrolment(socket.assigns.enrolment, enrolment_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp value_mapper(%User{} = user), do: {user.name, user.attendee.id}

  defp value_mapper(id), do: id
end
