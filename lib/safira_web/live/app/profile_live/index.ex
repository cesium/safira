defmodule SafiraWeb.App.ProfileLive.Index do
  use SafiraWeb, :app_view

  import SafiraWeb.Components.Page
  import SafiraWeb.Components.Avatar

  alias Safira.Accounts

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    profile_changeset = Accounts.change_user_registration(user, %{})
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:email_form_current_password, nil)
      |> assign(:password_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params

    changeset = Accounts.change_user_profile(socket.assigns.current_user, user_params)
    {:noreply, socket |> assign(profile_form: to_form(changeset, action: :validate))}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params

    case Accounts.update_user_profile(socket.assigns.current_user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully.")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update profile.")}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"email_form_current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     socket
     |> assign(email_form: email_form)
     |> assign(email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"email_form_current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."

        {:noreply,
         socket
         |> assign(email_form_current_password: nil)
         |> put_flash(:info, info)}

      {:error, changeset} ->
        email_form =
          changeset
          |> Map.put(:action, :insert)
          |> to_form()

        {:noreply,
         socket
         |> assign(email_form: email_form)
         |> put_flash(:error, "Failed to update email.")}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"password_form_current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     socket
     |> assign(password_form: password_form)
     |> assign(password_form_current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"password_form_current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply,
         socket
         # TODO: Fix the redirect page
         |> assign(trigger_submit: true, password_form: password_form)
         |> put_flash(:info, "Password updated successfully.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(password_form: to_form(changeset))
         |> put_flash(:error, "Failed to update password.")}
    end
  end
end
