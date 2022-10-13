defmodule SafiraWeb.RouletteController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Roulette

  action_fallback SafiraWeb.FallbackController

  def spin(conn, _params) do
    attendee = Accounts.get_user(conn) |> Map.fetch!(:attendee)

    cond do
      not is_nil(attendee) ->
        case Roulette.spin(attendee) do
          {:ok, changes} ->
            render(conn, "roulette.json", changes)

          {:error, :not_enough_tokens} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Insufficient token balance"})
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Only attendees can spin the wheel"})
    end
  end

  def latest_wins(conn, _params) do
    latest_prizes = Roulette.latest_five_wins()
    render(conn, "latest_prizes.json", latest_prizes: latest_prizes)
  end
end
