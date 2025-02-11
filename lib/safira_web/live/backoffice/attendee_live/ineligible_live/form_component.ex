defmodule SafiraWeb.Backoffice.AttendeeLive.IneligibleLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title="Eligibility"
        subtitle={gettext("Eligibility settings for %{name}.", name: assigns.attendee.user.name)}
      >
        <.simple_form
          for={@form}
          id="ineligible-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.field field={@form[:ineligible]} label="Ineligible" type="switch" />
          <:actions>
            <.button phx-disable-with="Saving...">
              <%= gettext("Save Eligibility") %>
            </.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:live_action, :default)}
  end

  @impl true
  def update(%{attendee: attendee} = assigns, socket) do
    form = Accounts.change_attendee(attendee, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(form)
     end)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"attendee" => attendee_params},
        socket
      ) do
    changeset = Accounts.change_attendee(socket.assigns.attendee, attendee_params)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"attendee" => attendee_params}, socket) do
    attendee = socket.assigns.attendee

    case Accounts.update_attendee(attendee, attendee_params) do
      {:ok, _attendee} ->
        {:noreply, socket |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("confirm-modal", _params, socket) do
    {:noreply, assign(socket, live_action: :confirm_eligibility)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, live_action: :default)}
  end
end
