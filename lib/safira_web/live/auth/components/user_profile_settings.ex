defmodule SafiraWeb.UserAuth.Components.UserProfileSettings do
  use SafiraWeb, :live_component

  alias Safira.Accounts

  import SafiraWeb.Components.Avatar
  import SafiraWeb.Components.Forms

  alias Safira.Accounts

  def update(assigns, socket) do
    user = assigns.user

    profile_changeset = Accounts.change_user_profile(user)

    # The new_user_session_changeset is used on the form that, on submit, creates a new user session, for the new password.
    # Since the user can change the email and pass at the same time on the main form, isn't possible use it to send the submit to create a new session
    # token, since the email isn't validated yet (need e-mail confirmation)
    new_user_session_changeset = Accounts.change_user_password(user)

    base_path = get_base_path_by_user_type(user)

    socket =
      socket
      |> assign(user: user)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(new_user_session_form: to_form(new_user_session_changeset))
      |> assign(current_password: nil)
      |> assign(trigger_form_action: false)
      |> assign(base_path: base_path)
      |> assign(notification_text: nil)

    {:ok, socket}
  end

  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => current_password} = user_params
    user = socket.assigns.user

    changeset = Accounts.change_user_profile(user, user_params)

    # The new_user_session_changeset need to be updated with the new password, but never with the new email (that will not be changed yet, on form submit)
    new_user_session_changeset =
      Accounts.change_user_password(user, %{
        email: user.email,
        password: Map.get(user_params, "password_confirmation", "")
      })

    {:noreply,
     socket
     |> assign(profile_form: to_form(changeset, action: :validate))
     |> assign(new_user_session_form: to_form(new_user_session_changeset))
     |> assign(current_password: current_password)}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => current_password} = user_params
    user = socket.assigns.user

    email_changed? = user.email != user_params["email"]

    password_changed? =
      user_params["password"] != nil && String.trim(user_params["password"]) != ""

    update_feedback = Accounts.update_user_profile(user, current_password, user_params)

    case update_feedback do
      {:ok, applied_user} ->
        profile_changeset =
          applied_user
          |> Accounts.change_user_profile()
          |> to_form()

        if email_changed? do
          Accounts.deliver_user_update_email_instructions(
            applied_user,
            user.email,
            &url(~p"/users/settings/confirm_email/#{&1}")
          )
        end

        info =
          "Profile updated successfully.
          #{if email_changed? do
            "A link to confirm your email change has been sent to the new address."
          else
            ""
          end}"

        {:noreply,
         socket
         |> assign(profile_form: profile_changeset)
         |> assign(user: applied_user)
         |> assign(current_password: nil)
         |> assign(trigger_form_action: password_changed?)
         |> assign(notification_text: info)
         |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(profile_form: to_form(changeset))}
    end
  end
end
