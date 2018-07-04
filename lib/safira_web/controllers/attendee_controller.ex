defmodule SafiraWeb.AttendeeController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.User

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Accounts.list_attendees()
    render(conn, "index.json", attendees: attendees)
  end

  def create(conn, %{"attendee" => attendee_params}) do
    with {:ok, %Attendee{} = attendee} <- Accounts.create_attendee(attendee_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", attendee_path(conn, :show, attendee))
      |> render("show.json", attendee: attendee)
    end
  end

  def show(conn, %{"id" => uuid}) do
    attendee = Accounts.get_attendee_uuid!(uuid)
    render(conn, "show.json", attendee: attendee)
  end

  def update(conn, %{"id" => uuid, "attendee" => attendee_params}) do
    attendee = Accounts.get_attendee_uuid!(uuid)

    if get_user(conn).attendee == attendee do
      with {:ok, %Attendee{} = attendee} <- 
          Accounts.update_attendee(attendee, attendee_params) do
        render(conn, "show.json", attendee: attendee)
      end
    end
  end

  def delete(conn, %{"id" => uuid}) do
    user = get_user(conn)
    attendee = Accounts.get_attendee_uuid!(uuid)
    if user.attendee == attendee do
      with {:ok, %Attendee{}} <- Accounts.delete_attendee(attendee),
           {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  defp get_user(conn) do
    Guardian.Plug.current_resource(conn)
    |> Map.fetch!(:id)
    |> Accounts.get_user_preload!()
  end
end
