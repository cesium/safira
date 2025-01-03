defmodule SafiraWeb.UserRegistrationLive do
  use SafiraWeb, :live_view

  alias Safira.Accounts
  alias Safira.Accounts.User

  import SafiraWeb.Components.Button

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    courses =
      Accounts.list_courses()
      |> Enum.map(fn c -> {c.name, c.id} end)

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:courses, courses)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_attendee_user(user_params) do
      {:ok, %{user: user, attendee: _}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign(check_errors: false)
         |> assign_form(changeset)
         |> push_navigate(to: ~p"/users/log_in")}

      {:error, _, %Ecto.Changeset{} = changeset, _} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)
         |> put_flash(:error, "Unable to register. Check the errors below")}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
