defmodule SafiraWeb.CompanyController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Company

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    companies = Accounts.list_companies()
    render(conn, "index.json", companies: companies)
  end

  def show(conn, %{"id" => id}) do
    company = Accounts.get_company!(id)
    render(conn, "show.json", company: company)
  end
end
