defmodule SafiraWeb.Admin.CompanyController do
  use SafiraWeb, :controller

  alias Safira.Admin.Accounts
  alias Safira.Accounts.Company

  plug(:put_layout, {SafiraWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Accounts.paginate_companies(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Companies. #{inspect(error)}")
        |> redirect(to: Routes.admin_company_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_company(%Company{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"company" => company_params}) do
    case Accounts.create_company(company_params) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Company created successfully.")
        |> redirect(to: Routes.admin_company_path(conn, :show, company))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    company = Accounts.get_company!(id)
    render(conn, "show.html", company: company)
  end

  def edit(conn, %{"id" => id}) do
    company = Accounts.get_company!(id)
    changeset = Accounts.change_company(company)
    render(conn, "edit.html", company: company, changeset: changeset)
  end

  def update(conn, %{"id" => id, "company" => company_params}) do
    company = Accounts.get_company!(id)

    case Accounts.update_company(company, company_params) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Company updated successfully.")
        |> redirect(to: Routes.admin_company_path(conn, :show, company))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    company = Accounts.get_company!(id)
    {:ok, _company} = Accounts.delete_company(company)

    conn
    |> put_flash(:info, "Company deleted successfully.")
    |> redirect(to: Routes.admin_company_path(conn, :index))
  end
end
