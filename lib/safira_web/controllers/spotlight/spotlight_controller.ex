defmodule SafiraWeb.SpotlightController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Interaction

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    is_admin = Accounts.is_admin(conn)

    if is_admin do
      companies = Accounts.list_companies()
      spotlight = Interaction.get_spotlight()

      conn
      |> put_status(:ok)
      |> render(:index, companies: companies, spotlight: spotlight)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end

  def current(conn, _params) do
    is_company = Accounts.is_company(conn)
    spotlight = Interaction.get_spotlight()

    if is_company do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    else
      if !spotlight || DateTime.compare(spotlight.end, DateTime.utc_now()) == :lt do
        conn
        |> put_status(:not_found)
        |> json(%{error: "Spotlight not found"})
        |> halt()
      else
        company = Accounts.get_company_by_badge!(spotlight.badge_id)

        conn
        |> put_status(:ok)
        |> render(:current, company: company, spotlight: spotlight)
      end
    end
  end

  def create(conn, %{"company_id" => company_id} = params) do
    is_admin = Accounts.is_admin(conn)

    if is_admin do
      company = Accounts.get_company!(company_id)

      with {:ok, _struct} <- Interaction.start_spotlight(company, params["duration"]) do
        conn
        |> put_status(:created)
        |> json(%{spotlight: "Spotlight created successfully"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end
end
