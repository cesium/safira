defmodule SafiraWeb.Backoffice.AttendeeLive.TokensLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Accounts
  alias Safira.Contest
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title="Tokens"
        subtitle={gettext("Token balance settings for %{name}.", name: assigns.attendee.user.name)}
      >
        <.simple_form
          for={assigns.form}
          id="tokens-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="confirm-modal"
        >
          <.field
            wrapper_class="col-span-4"
            value={@option}
            placeholder="Select an action type"
            options={["Add", "Remove"]}
            name="set_action"
            label="Action"
            type="select"
            required
          />
          <.field field={assigns.form[:tokens]} type="number" value={0} label="Tokens" required />
          <:actions>
            <.button phx-disable-with="Saving...">
              <%= gettext("Save Tokens") %>
            </.button>
          </:actions>
        </.simple_form>
      </.page>

      <.modal
        :if={@live_action in [:confirm_tokens]}
        id="tokens-confirm-modal"
        show
        on_cancel={JS.patch(~p"/dashboard/attendees/#{assigns.attendee.id}")}
      >
        <div class="mb-8">
          <h2 class="text-xl font-regular">
            <%= gettext(
              "Do you want to save these changes? This will leave %{name} with %{tokens} tokens.",
              name: @attendee.user.name,
              tokens: @current_tokens
            ) %>
          </h2>
        </div>
        <div class="flex flex-row gap-x-4">
          <.button phx-click="save" phx-target={@myself} class="w-full">
            <%= gettext("Confirm") %>
          </.button>

          <.button phx-click="cancel" phx-value="Remove" phx-target={@myself} class="w-full">
            <%= gettext("Cancel") %>
          </.button>
        </div>
      </.modal>
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
     |> assign(:current_tokens, attendee.tokens)
     |> assign(:option, "Add")
     |> assign_new(:form, fn ->
       to_form(form)
     end)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"attendee" => %{"tokens" => tokens} = attendee_params, "set_action" => action} =
          _params,
        socket
      ) do
    case {tokens, action} do
      {"", _} ->
        {:noreply, socket}

      {tokens, "Add"} ->
        tokens_int = String.to_integer(tokens)
        changeset = Accounts.change_attendee(socket.assigns.attendee, attendee_params)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, action: :validate))
         |> assign(:option, "Add")
         |> assign(:current_tokens, socket.assigns.attendee.tokens + tokens_int)}

      {tokens, "Remove"} ->
        tokens_int = String.to_integer(tokens)
        current_tokens = max(0, socket.assigns.attendee.tokens - tokens_int)
        changeset = Accounts.change_attendee(socket.assigns.attendee, attendee_params)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, action: :validate))
         |> assign(:option, "Remove")
         |> assign(:current_tokens, current_tokens)}
    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    attendee = socket.assigns.attendee
    tokens = socket.assigns.current_tokens

    case Contest.change_attendee_tokens(attendee, tokens) do
      {:ok, _attendee} ->
        {:noreply, socket |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("confirm-modal", _params, socket) do
    {:noreply, assign(socket, live_action: :confirm_tokens)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, live_action: :default)}
  end
end
