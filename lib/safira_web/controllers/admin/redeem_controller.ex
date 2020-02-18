defmodule SafiraWeb.Admin.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Admin.Contest
  alias Safira.Contest.Redeem

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Contest.paginate_redeems(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Redeems. #{inspect(error)}")
        |> redirect(to: Routes.admin_redeem_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Contest.change_redeem(%Redeem{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"redeem" => redeem_params}) do
    case Contest.create_redeem(redeem_params) do
      {:ok, redeem} ->
        conn
        |> put_flash(:info, "Redeem created successfully.")
        |> redirect(to: Routes.admin_redeem_path(conn, :show, redeem))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    redeem = Contest.get_redeem!(id)
    render(conn, "show.html", redeem: redeem)
  end

  def edit(conn, %{"id" => id}) do
    redeem = Contest.get_redeem!(id)
    changeset = Contest.change_redeem(redeem)
    render(conn, "edit.html", redeem: redeem, changeset: changeset)
  end

  def update(conn, %{"id" => id, "redeem" => redeem_params}) do
    redeem = Contest.get_redeem!(id)

    case Contest.update_redeem(redeem, redeem_params) do
      {:ok, redeem} ->
        conn
        |> put_flash(:info, "Redeem updated successfully.")
        |> redirect(to: Routes.admin_redeem_path(conn, :show, redeem))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", redeem: redeem, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    redeem = Contest.get_redeem!(id)
    {:ok, _redeem} = Contest.delete_redeem(redeem)

    conn
    |> put_flash(:info, "Redeem deleted successfully.")
    |> redirect(to: Routes.admin_redeem_path(conn, :index))
  end
end
