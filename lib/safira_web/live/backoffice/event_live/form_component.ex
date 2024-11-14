defmodule SafiraWeb.Backoffice.EventLive.FormComponent do
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Safira.Event

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("Generic event settings. Careful with what you change.")}
      >
        <.simple_form
          for={@form}
          id="event-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:registrations_open]} type="checkbox" label="Registrations Open" />
              <.field
                field={@form[:start_time]}
                type="datetime-local"
                label="Start Date/Time"
                required
              />
            </div>
          </div>
          <:actions>
            <.button
              data-confirm="Do you want to save these changes? It can break stuff if you are not careful"
              phx-disable-with="Saving..."
            >
              <%= gettext("Save Settings") %>
            </.button>
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
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", params, socket) do
    Event.change_registrations_open(string_to_bool(params["registrations_open"]))
    Event.change_event_start_time(parse_date(params["start_time"]))

    {:noreply,
     socket
     |> put_flash(:info, "Event settings updated successfully")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp parse_date(date_str) do
    {:ok, date, _} = DateTime.from_iso8601("#{date_str}:00Z")
    date
  end

  defp string_to_bool(str) do
    case String.downcase(str) do
      "true" -> true
      _ -> false
    end
  end
end
