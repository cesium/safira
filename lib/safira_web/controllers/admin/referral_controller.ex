defmodule SafiraWeb.Admin.ReferralController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Admin.Contest
  alias Safira.Contest.Referral

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Contest.paginate_referrals(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Referrals. #{inspect(error)}")
        |> redirect(to: Routes.admin_referral_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Contest.change_referral(%Referral{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"referral" => referral_params}) do
    case Contest.create_referral(referral_params) do
      {:ok, referral} ->
        conn
        |> put_flash(:info, "Referral created successfully.")
        |> redirect(to: Routes.admin_referral_path(conn, :show, referral))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    render(conn, "show.html", referral: referral)
  end

  def edit(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    changeset = Contest.change_referral(referral)
    render(conn, "edit.html", referral: referral, changeset: changeset)
  end

  def update(conn, %{"id" => id, "referral" => referral_params}) do
    referral = Contest.get_referral!(id)

    case Contest.update_referral(referral, referral_params) do
      {:ok, referral} ->
        conn
        |> put_flash(:info, "Referral updated successfully.")
        |> redirect(to: Routes.admin_referral_path(conn, :show, referral))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", referral: referral, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    {:ok, _referral} = Contest.delete_referral(referral)

    conn
    |> put_flash(:info, "Referral deleted successfully.")
    |> redirect(to: Routes.admin_referral_path(conn, :index))
  end
end
