defmodule SafiraWeb.AttendeeController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.User

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Accounts.list_active_attendees()
    render(conn, "index.json", attendees: attendees)
  end

  def show(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    cond do
      is_nil attendee.user_id ->
        {:error, :not_registered}
      true ->
        render(conn, "show.json", attendee: attendee)
    end
  end

  def update(conn, %{"id" => id, "attendee" => attendee_params}) do
    user = get_user(conn)
    attendee = Accounts.get_attendee!(id)
    if user.attendee.id == attendee.id do
      with {:ok, %Attendee{} = attendee} <-
          Accounts.update_attendee(attendee, attendee_params) do
            render(conn, "show.json", attendee: attendee)
      end
    else
      {:error, :unauthorized}
    end
  end

  def delete(conn, %{"id" => id}) do
    user = get_user(conn)
    user_attendee = Accounts.get_attendee!(user.attendee.id)
    attendee = Accounts.get_attendee!(id)
    if user_attendee == attendee do
      with {:ok, %Attendee{}} <- Accounts.delete_attendee(attendee),
           {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  defp get_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> Accounts.get_user_preload!()
    end
  end
end
