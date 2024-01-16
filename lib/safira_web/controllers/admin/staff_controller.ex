defmodule SafiraWeb.Admin.StaffController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts.Staff
  alias Safira.Admin.Accounts

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Accounts.paginate_staffs(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Staffs. #{inspect(error)}")
        |> redirect(to: Routes.admin_staff_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_staff(%Staff{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"staff" => staff_params}) do
    case Accounts.create_staff(staff_params) do
      {:ok, staff} ->
        conn
        |> put_flash(:info, "Staff created successfully.")
        |> redirect(to: Routes.admin_staff_path(conn, :show, staff))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    staff = Accounts.get_staff!(id)
    render(conn, "show.html", staff: staff)
  end

  def edit(conn, %{"id" => id}) do
    staff = Accounts.get_staff!(id)
    changeset = Accounts.change_staff(staff)
    render(conn, "edit.html", staff: staff, changeset: changeset)
  end

  def update(conn, %{"id" => id, "staff" => staff_params}) do
    staff = Accounts.get_staff!(id)

    case Accounts.update_staff(staff, staff_params) do
      {:ok, staff} ->
        conn
        |> put_flash(:info, "Staff updated successfully.")
        |> redirect(to: Routes.admin_staff_path(conn, :show, staff))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", staff: staff, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    staff = Accounts.get_staff!(id)
    {:ok, _staff} = Accounts.delete_staff(staff)

    conn
    |> put_flash(:info, "Staff deleted successfully.")
    |> redirect(to: Routes.admin_staff_path(conn, :index))
  end
end
