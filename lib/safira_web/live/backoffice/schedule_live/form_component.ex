defmodule SafiraWeb.Backoffice.ScheduleLive.FormComponent do
  @moduledoc false
  use SafiraWeb, :live_component

  import SafiraWeb.Components.Forms

  alias Ecto.Changeset
  alias Safira.Event

  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Configures the event's dates.")}>
        <div class="my-8">
          <.form
            id="event-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <div class="grid grid-cols-2 gap-2">
              <.field
                field={@form[:event_start_date]}
                name="event_start_date"
                label="Start date"
                type="date"
              />
              <.field
                field={@form[:event_end_date]}
                name="event_end_date"
                label="End date"
                type="date"
              />
            </div>
            <div class="flex flex-row-reverse">
              <.button phx-disable-with="Saving...">Save Configuration</.button>
            </div>
          </.form>
        </div>
      </.page>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       form:
         to_form(
           %{
             "event_start_date" => Event.get_event_start_date(),
             "event_end_date" => Event.get_event_end_date()
           },
           as: :wheel_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params["event_start_date"], params["event_end_date"])

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :event_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Event.change_event_start_date(params["event_start_date"] |> Date.from_iso8601!())
      Event.change_event_end_date(params["event_end_date"] |> Date.from_iso8601!())
      {:noreply, socket |> push_patch(to: ~p"/dashboard/schedule/activities/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(event_start_date, event_end_date) do
    {%{}, %{event_start_date: :date, event_end_date: :date}}
    |> Changeset.cast(%{event_start_date: event_start_date, event_end_date: event_end_date}, [
      :event_start_date,
      :event_end_date
    ])
    |> Changeset.validate_required([:event_start_date])
    |> Changeset.validate_required([:event_end_date])
    |> validate_date_is_after()
  end

  defp valid_config?(params) do
    validation = validate_configuration(params["event_start_date"], params["event_end_date"])
    validation.errors == []
  end

  defp validate_date_is_after(changeset) do
    start_date = Changeset.get_field(changeset, :event_start_date)
    end_date = Changeset.get_field(changeset, :event_end_date)

    if Date.compare(start_date, end_date) == :gt do
      Changeset.add_error(changeset, :event_start_date, "cannot be later than the end date")
    else
      changeset
    end
  end
end
