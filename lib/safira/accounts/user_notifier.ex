defmodule Safira.Accounts.UserNotifier do
  @moduledoc """
  User email notifications.
  """
  import Swoosh.Email

  alias Safira.Mailer

  use Phoenix.Swoosh, view: SafiraWeb.EmailView

  defp base_email(opts) do
    new()
    |> to(opts[:to])
    |> from({Mailer.get_sender_name(), Mailer.get_sender_address()})
  end

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    sender = {Mailer.get_sender_name(), Mailer.get_sender_address()}

    email =
      new()
      |> to(recipient)
      |> from(sender)
      |> subject("[#{elem(sender, 0)}] #{subject}")
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    # deliver(user.email, "Reset password instructions", """

    # ==============================

    # Hi #{user.email},

    # You can reset your password by visiting the URL below:

    # #{url}

    # If you didn't request this change, please ignore this.

    # ==============================
    # """)
    email =
      base_email(to: user.email)
      |> subject("Reset password instructions")
      |> assign(:user_name, user.name)
      |> assign(:reset_password_link, url)
      |> render_body("reset_password.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
