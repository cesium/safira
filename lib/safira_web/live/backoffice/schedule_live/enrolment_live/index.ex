defmodule SafiraWeb.Backoffice.ScheduleLive.EnrolmentLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Activities

  import SafiraWeb.Components.{EnsurePermissions, Table, TableSearch}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"enrolments" => ["show"]}}>
            <.link navigate={~p"/dashboard/scanner/enrolments/#{@activity_id}"}>
              <.button>
                <.icon name="hero-qr-code" class="w-5 h-5" />
              </.button>
            </.link>
          </.ensure_permissions>
          <.ensure_permissions user={@current_user} permissions={%{"enrolments" => ["edit"]}}>
            <.link navigate={~p"/dashboard/schedule/activities/#{@activity_id}/enrolments/new"}>
              <.button>New Enrolment</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <div class="pt-4 flex flex-col gap-2 h-[30.5rem]">
          <.table_search
            id="enrolment-table-name-search"
            params={@params}
            field={:name}
            path={~p"/dashboard/schedule/activities/#{@activity_id}/enrolments"}
            placeholder={gettext("Search for enrolments")}
            class="w-full"
          />
          <.table
            id="enrolment-table"
            items={@streams.enrolled_attendees}
            meta={@meta}
            params={@params}
          >
            <:col :let={{_id, attendee}} sortable field={:name} label="Name">
              <div class="flex gap-4 flex-center items-center">
                <.avatar
                  src={
                    Uploaders.UserPicture.url({attendee.picture, attendee}, :original, signed: true)
                  }
                  handle={attendee.name}
                />
                <div class="self-center">
                  <p class="text-base font-semibold"><%= attendee.name %></p>
                </div>
              </div>
            </:col>
            <:action :let={{id, user}}>
              <.ensure_permissions user={@current_user} permissions={%{"enrolments" => ["edit"]}}>
                <div class="flex flex-row gap-2">
                  <.link
                    phx-click={
                      JS.push("delete-enrolment",
                        value: %{activity_id: @activity_id, attendee_id: user.attendee.id},
                        target: @myself
                      )
                      |> hide("##{id}")
                    }
                    data-confirm="Are you sure?"
                  >
                    <.icon name="hero-trash" class="w-5 h-5" />
                  </.link>
                </div>
              </.ensure_permissions>
            </:action>
          </.table>
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
  def handle_event(
        "delete-enrolment",
        %{"activity_id" => activity_id, "attendee_id" => attendee_id},
        socket
      ) do
    Activities.unenrol(activity_id, attendee_id)

    # Remove the enrolment from the list
    {:noreply,
     socket
     |> stream_delete(
       :enrolled_attendees,
       Accounts.get_attendee!(attendee_id)
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
      Enum.each(enrolments, fn {_, new, _enrolment, form} ->
        if new, do: Activities.enrol(form.params["attendee_id"], form.params["activity_id"])
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Enrolments changed successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply, socket}
    end
  end

  defp has_duplicates?(list), do: Enum.uniq(list) != list
end
