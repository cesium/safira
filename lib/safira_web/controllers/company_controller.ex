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

  def update(conn, %{"id" => id, "company" => company_params}) do
    cond do
      Accounts.is_manager(conn) ->
        with {:ok, %Company{} = company} <-
               Accounts.get_company!(id) |> Accounts.update_company(company_params) do
          render(conn, "show.json", company: company)
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
    end
  end
end
