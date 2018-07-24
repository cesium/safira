defmodule SafiraWeb.StaffController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Staff
  alias Safira.Accounts.User

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    staffs = Accounts.list_staffs()
    render(conn, "index.json", staffs: staffs)
  end

  def create(conn, %{"staff" => staff_params}) do
    with {:ok, %staff{} = staff} <- Accounts.create_staff(staff_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", staff_path(conn, :show, staff))
      |> render("show.json", staff: staff)
    end
  end

  def show(conn, %{"id" => id}) do
    staff = Accounts.get_staff!(id)
    render(conn, "show.json", staff: staff)
  end

  def update(conn, %{"id" => id, "staff" => staff_params}) do
    staff = Accounts.get_staff!(id)

    if get_user(conn).staff == staff do
      with {:ok, %staff{} = staff} <-
          Accounts.update_staff(staff, staff_params) do
        render(conn, "show.json", staff: staff)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = get_user(conn)
    staff = Accounts.get_staff!(id)
    if user.staff == staff do
        with {:ok, %Staff{}} <- Accounts.delete_staff(staff),
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
