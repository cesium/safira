defmodule SafiraWeb.SpotlightController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Interaction

  action_fallback SafiraWeb.FallbackController

  def create(conn, _params) do
    user = Accounts.get_user(conn)

    cond do
      Accounts.is_company(conn) ->
        with {:ok, _struct} <- Interaction.start_spotlight(user.company.badge_id) do
          spotlight_discord_request(user.company.name, "POST") # to signal discord to start the spotlight

          schedule_spotlight_finish(user.company.name)

          conn
          |> put_status(:created)
          |> json(%{spotlight: "Spotlight requested succesfully",})
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
        |> halt()
    end
  end

  defp spotlight_discord_request(company_name, request_type) do
    headers = %{"Content-Type" => "application/json",
     "Authorization" => System.get_env("DISCORD_BOT_API_KEY")}

    url = "#{System.get_env("DISCORD_BOT_URL")}/spotlight"

    case request_type do
      "POST" ->
        body = Poison.encode! %{"company" => company_name}
        HTTPoison.post(url,body, headers, [])

      "DELETE" -> HTTPoison.delete(url, headers)
    end

  end

  defp schedule_spotlight_finish(company_name) do
    Task.async(fn ->
      :timer.sleep(20*1000)
      Interaction.finish_spotlight()
      spotlight_discord_request(company_name, "DELETE") #To signal discord to end the spotlight
    end)
  end
end
