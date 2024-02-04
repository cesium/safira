defmodule SafiraWeb.CompanyController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    companies = Accounts.list_companies()
    render(conn, "index.json", companies: companies)
  end

  def show(conn, %{"id" => id}) do
    company = Accounts.get_company!(id)
    render(conn, "show.json", company: company)
  end

  def company_attendees(conn, %{"id" => company_id}) do
    attendees = Accounts.list_company_attendees(company_id)
    current_user = Accounts.get_user(conn)
    if Accounts.is_company(conn) and current_user.company.id == String.to_integer(company_id) do
      render(conn, "index_attendees.json",
        attendees: attendees,
        show_cv: current_user.company.has_cv_access
      )
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end
end
