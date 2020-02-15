defmodule SafiraWeb.Admin.BadgeController do
  use SafiraWeb, :controller

  alias Safira.Admin.Contest
  alias Safira.Contest.Badge

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Contest.paginate_badges(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Badges. #{inspect(error)}")
        |> redirect(to: Routes.admin_badge_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Contest.change_badge(%Badge{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"badge" => badge_params}) do
    case Contest.create_badge(badge_params) do
      {:ok, badge} ->
        conn
        |> put_flash(:info, "Badge created successfully.")
        |> redirect(to: Routes.admin_badge_path(conn, :show, badge))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    render(conn, "show.html", badge: badge)
  end

  def edit(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    changeset = Contest.change_badge(badge)
    render(conn, "edit.html", badge: badge, changeset: changeset)
  end

  def update(conn, %{"id" => id, "badge" => badge_params}) do
    badge = Contest.get_badge!(id)

    case Contest.update_badge(badge, badge_params) do
      {:ok, badge} ->
        conn
        |> put_flash(:info, "Badge updated successfully.")
        |> redirect(to: Routes.admin_badge_path(conn, :show, badge))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", badge: badge, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    {:ok, _badge} = Contest.delete_badge(badge)

    conn
    |> put_flash(:info, "Badge deleted successfully.")
    |> redirect(to: Routes.admin_badge_path(conn, :index))
  end
end
