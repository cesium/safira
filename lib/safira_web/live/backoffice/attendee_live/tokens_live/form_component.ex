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
          <.field
            field={assigns.form[:tokens]}
            type="number"
            value={@amount}
            min="1"
            step="1"
            label="Tokens"
            required
          />
          <p :if={@amount != "" and is_nil(@amount_int)} class="text-sm text-red-600">
            {gettext("Tokens must be a whole number greater than 0.")}
          </p>
          <:actions>
            <.button phx-disable-with="Saving..." disabled={is_nil(@amount_int)}>
              {gettext("Save Tokens")}
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
            {gettext(
              "Do you want to save these changes? This will leave %{name} with %{tokens} tokens.",
              name: @attendee.user.name,
              tokens: @current_tokens
            )}
          </h2>
        </div>
        <div class="flex flex-row gap-x-4">
          <.button phx-click="save" phx-target={@myself} class="w-full">
            {gettext("Confirm")}
          </.button>

          <.button phx-click="cancel" phx-value="Remove" phx-target={@myself} class="w-full">
            {gettext("Cancel")}
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
     |> assign(:amount, "")
     |> assign(:amount_int, nil)
     |> assign_new(:form, fn ->
       to_form(form)
     end)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"attendee" => %{"tokens" => tokens}, "set_action" => action},
        socket
      ) do
    amount_int = parse_amount(tokens)

    {:noreply,
     socket
     |> assign(:option, action)
     |> assign(:amount, tokens)
     |> assign(:amount_int, amount_int)
     |> assign(:current_tokens, new_balance(socket.assigns.attendee.tokens, amount_int, action))}
  end

  @impl true
  def handle_event("save", _params, socket) do
    attendee = socket.assigns.attendee
    tokens = socket.assigns.current_tokens

    if is_nil(socket.assigns.amount_int) do
      {:noreply, assign(socket, live_action: :default)}
    else
      case Contest.change_attendee_tokens(attendee, tokens) do
        {:ok, _changes} ->
          {:noreply, socket |> push_navigate(to: socket.assigns.patch)}

        {:error, _operation, _value, _changes} ->
          {:noreply,
           socket
           |> assign(live_action: :default)
           |> put_flash(:error, gettext("Could not update the tokens. Please try again."))}
      end
    end
  end

  @impl true
  def handle_event("confirm-modal", _params, socket) do
    if is_nil(socket.assigns.amount_int) do
      {:noreply, socket}
    else
      {:noreply, assign(socket, live_action: :confirm_tokens)}
    end
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, live_action: :default)}
  end

  # Tokens are always whole numbers; the action (Add/Remove) gives the direction,
  # so the amount must be a positive integer. Anything else ("", "1.5", "1e2", "-5") is invalid.
  defp parse_amount(value) do
    case Integer.parse(value) do
      {amount, ""} when amount > 0 -> amount
      _ -> nil
    end
  end

  defp new_balance(current, nil, _action), do: current
  defp new_balance(current, amount, "Add"), do: current + amount
  defp new_balance(current, amount, "Remove"), do: max(0, current - amount)
end
