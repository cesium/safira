defmodule Safira.Accounts.UserNotifier do
  @moduledoc """
  User email notifications.
  """
  import Swoosh.Email

  alias Safira.Mailer

  use Phoenix.Swoosh, view: SafiraWeb.EmailView

  defp base_html_email(recipient, subject) do
    sender = {Mailer.get_sender_name(), Mailer.get_sender_address()}

    phx_host =
      if System.get_env("PHX_HOST") != nil do
        "https://" <> System.get_env("PHX_HOST")
      else
        ""
      end

    new()
    |> to(recipient)
    |> from(sender)
    |> subject("[#{elem(sender, 0)}] #{subject}")
    |> assign(:phx_host, phx_host)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    email =
      base_html_email(user.email, "Confirm your email")
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
      base_html_email(user.email, "Reset your password")
      |> assign(:user_name, user.name)
      |> assign(:reset_password_link, url)
      |> render_body("reset_password.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deliver welcome email.
  """
  def deliver_welcome_email(user) do
    email =
      base_html_email(user.email, "Welcome to SEI")
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
    email =
      base_html_email(user.email, "Change your email")
      |> assign(:user_name, user.name)
      |> assign(:confirm_email_link, url)
      |> render_body("confirm_email_change.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end
end
