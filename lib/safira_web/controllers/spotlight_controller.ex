defmodule SafiraWeb.SpotlightController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Interaction

  action_fallback SafiraWeb.FallbackController

  def create(conn, _params) do
    user = Accounts.get_user(conn)

    cond do
      Accounts.is_company(conn) ->
        with {:ok, _struct} <- Interaction.start_spotlight(user.company) do
          # to signal discord to start the spotlight
          spotlight_discord_request(user.company.name, :post)

          schedule_spotlight_finish(user.company.name)

          conn
          |> put_status(:created)
          |> json(%{spotlight: "Spotlight requested succesfully"})
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
        |> halt()
    end
  end

  defp spotlight_discord_request(company_name, request_type) do
    headers = %{
      "Content-Type" => "application/json",
      "Authorization" => Application.fetch_env!(:safira, :discord_bot_api_key)
    }

    url = "#{Application.fetch_env!(:safira, :discord_bot_url)}/spotlight"

    case request_type do
      :post ->
        body = Poison.encode!(%{"company" => company_name})
        HTTPoison.post(url, body, headers, [])

      :delete ->
        HTTPoison.delete(url, headers)
    end
  end

  defp schedule_spotlight_finish(company_name) do
    Task.async(fn ->
      :timer.sleep(Application.fetch_env!(:safira, :spotlight_duration) * 60 * 1000)
      Interaction.finish_spotlight()
      # To signal discord to end the spotlight
      spotlight_discord_request(company_name, :delete)
    end)
  end
end
