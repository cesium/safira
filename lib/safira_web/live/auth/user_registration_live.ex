defmodule SafiraWeb.UserRegistrationLive do
  use SafiraWeb, :landing_view

  alias Safira.Accounts
  alias Safira.Accounts.User

  import SafiraWeb.Components.Button

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      socket
      |> assign(form: form, errors: false)
    else
      assign(socket, form: form, errors: true)
    end
  end
end
