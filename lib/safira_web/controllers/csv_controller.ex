defmodule SafiraWeb.CSVController do
  use SafiraWeb, :controller
  alias NimbleCSV.RFC4180, as: CSV

  alias Safira.Accounts

  def final_draw(conn, _params) do
    if user_authorized?(conn.assigns.current_user) do
      conn =
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"large_data.csv\"")
        |> send_chunked(200)

      # Stream the data
      Accounts.list_attendees()
      |> Stream.flat_map(&final_draw_lines/1)
      |> Stream.map(&CSV.dump_to_iodata(&1))
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

  defp user_authorized?(user) do
    not is_nil(user.staff) and
      Enum.member?(Map.get(user.staff.role.permissions, "statistics"), "show")
  end

  defp final_draw_lines(attendee) do
    for _ <- 1..attendee.attendee.entries do
      [[attendee.id, attendee.name, attendee.handle]]
    end
  end
end
