defmodule SafiraWeb.CVController do
  use SafiraWeb, :controller

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

    if Accounts.is_admin(conn) or curr_company_id == company.id do
      attendees_cvs =
        Accounts.list_company_attendees(company_id)
        |> Enum.filter(fn x -> x.cv != nil end)
        |> Enum.map(fn x -> {x.nickname, CV.storage_dir(x)} end)
        |> Enum.map(fn {nickname, storage_dir} ->
          {nickname,
           File.ls!(storage_dir)
           |> List.first() # should never return nil because we enure the attendee has a CV
           |> (fn file_name -> Path.join(storage_dir, file_name) end).()
           |> File.read()}
        end)
        |> Enum.filter(fn {_, {s, _}} -> s == :ok end)
        |> Enum.map(fn {nickname, {_, data}} ->
          {(nickname <> ".pdf")
           |> String.to_charlist(), data}
        end)

      {:ok, {zip_filename, zip_bin}} = :zip.create('cvs.zip', attendees_cvs, [:memory])

      conn
      |> put_status(:ok)
      |> send_download({:binary, zip_bin}, [{:filename, "#{zip_filename}"}])
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{
        error: "The CVs of a company's attendees can only be accessed by the company or by the admin",
        company_id: company_id,
        user: curr_company_id
      })
    end
  end
end
