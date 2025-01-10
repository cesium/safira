# TO fix:
# redirect da password
# notificacoes
# refazer o  status

defmodule SafiraWeb.UserAuth.Components.UserProfileSettings do
  use SafiraWeb, :live_component

  alias Safira.Accounts

  import SafiraWeb.Components.Avatar
  import SafiraWeb.Components.Forms

  alias Safira.Accounts

  def update(assigns, socket) do
    user = assigns.user

    profile_changeset = Accounts.change_user_profile(user)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => current_password} = user_params
    user = socket.assigns.user

    changeset = Accounts.change_user_profile(user, user_params)

    {:noreply,
     socket
     |> assign(profile_form: to_form(changeset, action: :validate))}
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
         |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(profile_form: to_form(changeset))}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "An unexpected error happened while updating the profile.")}
    end
  end

  #    case Accounts.update_user_password(user, password, user_params) do
  #      {:ok, user} ->
  #        password_form =
  #          user
  #          |> Accounts.change_user_password(user_params)
  #          |> to_form()
  #
  #        {:noreply,
  #         socket
  #         # TODO: Fix the redirect page
  #         |> assign(trigger_submit: true, password_form: password_form)
  #         |> put_flash(:info, "Password updated successfully.")}
end
