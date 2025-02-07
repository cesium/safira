defmodule SafiraWeb.UserRoles do
  @moduledoc """
  Plugs for user type verification.
  """
  use SafiraWeb, :verified_routes

  use Gettext, backend: SafiraWeb.Gettext

  import Plug.Conn
  import Phoenix.Controller

  alias Safira.Accounts

  def require_confirmed_user(conn, _opts) do
    if is_nil(conn.assigns.current_user.confirmed_at) do
      conn
      |> redirect(to: ~p"/users/confirmation_pending")
      |> halt()
    else
      conn
    end
  end

  def require_credential(conn, _opts) do
    if has_credential?(conn) do
      conn
    else
      conn
      |> put_flash(
        :error,
        gettext(
          "You haven't assigned a credential to your account. You need one to participate in the event."
        )
      )
      |> redirect(to: ~p"/app/credential/link")
      |> halt()
    end
  end

  def require_no_credential(conn, _opts) do
    if has_credential?(conn) do
      conn
      |> put_flash(
        :error,
        gettext("You already have a credential assigned to your account.")
      )
      |> redirect(to: ~p"/app")
      |> halt()
    else
      conn
    end
  end

  defp has_credential?(conn) do
    is_nil(conn.assigns.current_user.attendee) or
      not is_nil(Accounts.get_credential_of_attendee(conn.assigns.current_user.attendee))
  end

  @doc """
  Used for routes that require the user to be an attendee.
  """
  def require_attendee_user(conn, _opts) do
    require_user_type(conn, :attendee)
  end

  @doc """
  Used for routes that require the user to be staff.
  """
  def require_staff_user(conn, _opts) do
    require_user_type(conn, :staff)
  end

  def require_company_user(conn, _opts) do
    require_user_type(conn, :company)
  end

  defp require_user_type(conn, type) do
    if conn.assigns[:current_user].type == type do
      conn
    else
      conn
      |> put_flash(:error, "You don't have access to this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
