defmodule SafiraWeb.SpotlightController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts
  alias Safira.Interaction

  action_fallback SafiraWeb.FallbackController

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
