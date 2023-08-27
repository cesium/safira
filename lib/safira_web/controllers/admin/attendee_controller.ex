defmodule SafiraWeb.Admin.AttendeeController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts.Attendee
  alias Safira.Admin.Accounts

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Accounts.paginate_attendees(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Attendees. #{inspect(error)}")
        |> redirect(to: Routes.admin_attendee_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_attendee(%Attendee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attendee" => attendee_params}) do
    case Accounts.create_attendee(attendee_params) do
      {:ok, attendee} ->
        conn
        |> put_flash(:info, "Attendee created successfully.")
        |> redirect(to: Routes.admin_attendee_path(conn, :show, attendee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    render(conn, "show.html", attendee: attendee)
  end

  def edit(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    changeset = Accounts.change_attendee(attendee)
    render(conn, "edit.html", attendee: attendee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "attendee" => attendee_params}) do
    attendee = Accounts.get_attendee!(id)

    case Accounts.update_attendee(attendee, attendee_params) do
      {:ok, attendee} ->
        conn
        |> put_flash(:info, "Attendee updated successfully.")
        |> redirect(to: Routes.admin_attendee_path(conn, :show, attendee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", attendee: attendee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    {:ok, _attendee} = Accounts.delete_attendee(attendee)

    conn
    |> put_flash(:info, "Attendee deleted successfully.")
    |> redirect(to: Routes.admin_attendee_path(conn, :index))
  end
end
