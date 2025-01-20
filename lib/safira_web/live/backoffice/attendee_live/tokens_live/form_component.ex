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
        subtitle={gettext("Tokens settings for %{name}.", name: assigns.attendee.user.name)}
      >
        <.simple_form
          for={assigns.form}
          id="tokens-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.field
            field={assigns.form[:tokens]}
            type="number"
            value={assigns.attendee.tokens}
            label="Tokens"
            required
          />
          <:actions>
            <.button
              data-confirm={"Do you wan to save these changes? #{assigns.attendee.user.name} will have #{get_tokens(assigns.form.params)} tokens."}
              phx-disable-with="Saving..."
            >
              <%= gettext("Save Tokens") %>
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
  def handle_event("validate", params, socket) do
    changeset = Accounts.change_attendee(socket.assigns.attendee, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"attendee" => %{"tokens" => tokens}}, socket) do
    attendee = socket.assigns.attendee

    case Contest.change_attendee_tokens(attendee, tokens) do
      {:ok, _attendee} ->
        {:noreply, socket |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  defp get_tokens(
         %{"_target" => ["attendee", "tokens"], "attendee" => %{"tokens" => tokens}} = _params
       ),
       do: tokens

  defp get_tokens(_params), do: 0
end
