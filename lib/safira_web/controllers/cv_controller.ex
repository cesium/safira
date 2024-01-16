defmodule SafiraWeb.CVController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts

  alias Safira.CV

  action_fallback SafiraWeb.FallbackController

  def company_cvs(conn, %{"id" => company_id}) do
    curr_user = Accounts.get_user(conn)

    curr_company_id =
      curr_user
      |> Map.get(:company)
      |> case do
        nil -> nil
        company -> Map.get(company, :id)
      end

    company = Accounts.get_company!(company_id)

    if Accounts.is_admin(conn) or (curr_company_id == company.id and company.has_cv_access) do
      zip =
        Accounts.list_company_attendees(company_id)
        |> Enum.filter(fn x -> x.cv != nil end)
        |> Enum.map(fn x ->
          Zstream.entry(
            x.nickname <> ".pdf",
            "#{System.get_env("CV_URL", "")}#{CV.url({x.cv, x})}"
            |> HTTPStream.get()
          )
        end)
        |> Zstream.zip()
        |> Enum.to_list()

      conn
      |> put_status(:ok)
      |> send_download({:binary, zip}, [{:filename, "cvs.zip"}])
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        error:
          "The CVs of a company's attendees can only be accessed by the company or by the admin",
        company_id: company_id,
        user: curr_company_id
      })
    end
  end
end
