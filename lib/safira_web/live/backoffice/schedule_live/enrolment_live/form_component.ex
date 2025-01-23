defmodule SafiraWeb.Backoffice.ScheduleLive.EnrolmentLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Activities
  alias Safira.Activities.Enrolment
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@activity.title}>
        <div class="py-8">
          <div class="flex flex-row justify-between items-center">
            <h2 class="font-semibold"><%= gettext("Enrolments") %></h2>
            <.button phx-click={JS.push("add-enrolment", target: @myself)}>
              <.icon name="hero-plus" class="w-5 h-5" />
            </.button>
          </div>

          <ul class="h-[45vh] overflow-y-scroll scrollbar-hide mt-4 border-b-[1px] border-lightShade  dark:border-darkShade">
            <%= for {id, new, enrolment, form} <- @enrolments do %>
              <li class="border-b-[1px] last:border-b-0 border-lightShade dark:border-darkShade">
                <%= if new do %>
                  <.simple_form id={id} for={form} phx-change="validate" phx-target={@myself} class="">
                    <.field type="hidden" name="identifier" value={id} />
                    <.field type="hidden" field={form[:activity_id]} value={@activity.id} />
                    <div class="grid space-x-2 grid-cols-9 pl-1">
                      <.field_multiselect
                        id={"attendees-#{id}"}
                        field={form[:attendee_id]}
                        target={@myself}
                        value_mapper={&attendee_options/1}
                        wrapper_class="w-full col-span-8"
                        placeholder={gettext("Search for attendees")}
                      />

                      <.link
                        phx-click={JS.push("delete-enrolment", value: %{id: id})}
                        data-confirm="Are you sure?"
                        phx-target={@myself}
                        class="content-center px-3"
                      >
                        <.icon name="hero-trash" class="w-5 h-5" />
                      </.link>
                    </div>
                  </.simple_form>
                <% else %>
                  <div class="grid space-x-2 grid-cols-9 pl-1 mb-6">
                    <p class="col-span-8"><%= enrolment.attendee.user.name %></p>
                    <.link
                      phx-click={JS.push("delete-enrolment", value: %{id: id})}
                      data-confirm="Are you sure?"
                      phx-target={@myself}
                      class="content-center px-3"
                    >
                      <.icon name="hero-trash" class="w-5 h-5" />
                    </.link>
                  </div>
                <% end %>
              </li>
            <% end %>
          </ul>
        </div>
        <div class="w-full flex flex-row-reverse">
          <.button phx-click="save" phx-target={@myself} phx-disable-with="Saving...">
            <%= gettext("Save Configuration") %>
          </.button>
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
  def update(assigns, socket) do
    enrolments =
      assigns.activity.enrolments
      |> Enum.map(fn enrolment ->
        {Ecto.UUID.generate(), false, enrolment, to_form(Activities.change_enrolment(enrolment))}
      end)

    {:ok,
     socket
     |> assign(:enrolments, enrolments)
     |> assign(:activity, assigns.activity)
     |> assign(:attendees, Accounts.list_attendees())}
  end

  @impl true
  def handle_event("validate", enrolment_params, socket) do
    enrolments = socket.assigns.enrolments
    enrolment = get_enrolment_data_by_id(enrolments, enrolment_params["identifier"])
    changeset = Activities.change_enrolment(enrolment, enrolment_params["enrolment"])

    # Update the form with the new changeset and the enrolment type if it changed
    enrolments =
      socket.assigns.enrolments
      |> update_enrolment_form(
        enrolment_params["identifier"],
        to_form(changeset, action: :validate)
      )

    {:noreply,
     socket
     |> assign(enrolments: enrolments)}
  end

  @impl true
  def handle_event("add-enrolment", _, socket) do
    enrolments = socket.assigns.enrolments

    # Add a new enrolment to the list
    {:noreply,
     socket
     |> assign(
       :enrolments,
       enrolments ++
         [
           {Ecto.UUID.generate(), true, %Enrolment{},
            to_form(Activities.change_enrolment(%Enrolment{}))}
         ]
     )}
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
  def handle_event("delete-enrolment", %{"id" => id}, socket) do
    enrolments = socket.assigns.enrolments
    # Find the enrolment to delete in the enrolments list
    enrolment =
      Enum.find(enrolments, fn {enrolment_id, _, _, _} -> enrolment_id == id end) |> elem(2)

    # If the enrolment has an id, delete it from the database
    if enrolment.id != nil do
      Activities.delete_enrolment(enrolment)
    end

    # Remove the enrolment from the list
    {:noreply,
     socket
     |> assign(
       enrolments: Enum.reject(enrolments, fn {enrolment_id, _, _, _} -> enrolment_id == id end)
     )}
  end

  @impl true
  def handle_event("save", _params, socket) do
    enrolments = socket.assigns.enrolments

    # Find if all the changesets are valid
    valid_enrolments =
      Enum.all?(enrolments, fn {_, _, _, form} -> form.source.valid? end) and
        not (enrolments
             |> Enum.map(fn {id, _, _, _} -> id end)
             |> has_duplicates?())

    if valid_enrolments do
      # For each enrolment, update or create it
      Enum.each(enrolments, fn {_, _, _enrolment, form} ->
        Activities.create_enrolment(form.params)
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Wheel configuration changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket}
    end
  end

  def get_enrolment_data_by_id(enrolments, id) do
    Enum.find(enrolments, &(elem(&1, 0) == id)) |> elem(2)
  end

  defp update_enrolment_form(enrolments, id, new_form) do
    Enum.map(enrolments, fn
      {^id, new, enrolment, _} -> {id, new, enrolment, new_form}
      other -> other
    end)
  end

  defp attendee_options(%User{} = user), do: {user.name, user.attendee.id}
  defp attendee_options(id), do: id

  defp has_duplicates?(list), do: Enum.uniq(list) != list
end
