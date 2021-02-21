defmodule SafiraWeb.RouletteController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Roulette

  action_fallback SafiraWeb.FallbackController

  def spin(conn, _params) do
    attendee = Accounts.get_user(conn) |> Map.fetch!(:attendee)
    cond do
       not is_nil(attendee)->
        with {:ok, changes} <- Roulette.spin(attendee) do
          render(conn, "roulette.json", changes)
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Only attendees can spin the wheel"})
    end
  end

  def latest_wins(conn, _params) do
    prizes = Roulette.latest_five_wins()
    render(conn, "latest_prizes.json", prizes: prizes)
  end
end
