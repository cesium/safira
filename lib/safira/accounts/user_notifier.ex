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
    email =
      base_email(to: user.email)
      |> subject("SEI | Confirm your email")
      |> assign(:user_name, user.name)
      |> assign(:confirm_email_link, url)
      |> render_body("confirm_email.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    email =
      base_email(to: user.email)
      |> subject("SEI | Reset password")
      |> assign(:user_name, user.name)
      |> assign(:reset_password_link, url)
      |> render_body("reset_password.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  def deliver_welcome_email(user) do
    email =
      base_email(to: user.email)
      |> subject("Welcome to SEI")
      |> assign(:user_name, user.name)
      |> render_body("welcome.html")

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
