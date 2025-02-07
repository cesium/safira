defmodule SafiraWeb.DownloadController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Companies

  def generate_credentials(conn, %{"count" => count}) do
    {count_int, ""} = Integer.parse(count)

    if user_authorized?(conn.assigns.current_user, "event", "generate_credentials") do
      conn =
        conn
        |> put_resp_content_type("application/zip")
        |> put_resp_header("content-disposition", "attachment; filename=qr_codes.zip")
        |> send_chunked(200)

      Accounts.generate_credentials(count_int)
      |> Enum.map(fn {id, png} -> Zstream.entry("#{id}.png", png) end)
      |> Zstream.zip()
      |> Enum.reduce(conn, fn chunk, conn ->
        case chunk(conn, chunk) do
          {:ok, conn} -> conn
          {:error, _reason} -> conn
        end
      end)
    else
      conn
      |> put_flash(:error, "You do not have permission to view this resource")
      |> put_status(403)
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def attendees_data(conn, _params) do
    if user_authorized?(conn.assigns.current_user, "event", "show") do
      data = write_attendees_csv()

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"attendees.csv\"")
      |> send_resp(200, data)
    else
      conn
      |> put_flash(:error, "You do not have permission to view this resource")
      |> put_status(403)
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def cv_challenge(conn, _params) do
    if user_authorized?(conn.assigns.current_user, "attendees", "show") do
      data = write_cv_challenge_csv()

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"cv_challenge.csv\"")
      |> send_resp(200, data)
    else
      conn
      |> put_flash(:error, "You do not have permission to view this resource")
      |> put_status(403)
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def cvs(conn, _params) do
    company = conn.assigns.current_user.company

    if is_nil(company.badge_id) do
      conn
      |> put_flash(:error, "You do not have permission to view this resource")
      |> redirect(to: ~p"/sponsor")
    else
      conn =
        conn
        |> put_resp_content_type("application/zip")
        |> put_resp_header("content-disposition", "attachment; filename=sei_cvs.zip")
        |> send_chunked(200)

      Companies.get_cvs(company)
      |> Enum.map(fn {handle, cv} ->
        Zstream.entry(
          handle <> ".pdf",
          [HTTPoison.get!(cv, [], follow_redirect: true).body]
        )
      end)
      |> Zstream.zip()
      |> Enum.reduce(conn, fn chunk, conn ->
        case chunk(conn, chunk) do
          {:ok, conn} -> conn
          {:error, _reason} -> conn
        end
      end)
    end
  end

  defp write_attendees_csv do
    Accounts.list_attendees(order_by: :inserted_at)
    |> Enum.map(fn user ->
      [
        "#{user.name},#{user.email},@#{user.handle},#{Timex.format!(user.inserted_at, "{0D}-{0M}-{YYYY} {h24}:{m}:{s}")},#{user.attendee.tokens},#{user.attendee.entries}"
      ]
    end)
    |> Kernel.then(fn l -> ["Name,Email,Username,Registered at,Tokens,Entries"] ++ l end)
    |> Enum.join("\n")
    |> to_string()
  end

  defp write_cv_challenge_csv do
    Accounts.list_attendees_with_cv()
    |> Enum.map(fn user ->
      [
        "#{user.id},#{user.name},#{user.handle}"
      ]
    end)
    |> Enum.join("\n")
    |> to_string()
  end

  defp user_authorized?(user, scope, action) do
    not is_nil(user.staff) and
      Enum.member?(Map.get(user.staff.role.permissions, scope), action)
  end
end
