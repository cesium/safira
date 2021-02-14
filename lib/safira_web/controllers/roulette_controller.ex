defmodule SafiraWeb.RouletteController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Roulette

  def spin(conn, _params) do
    attendee = Accounts.get_user(conn) |> Map.fetch!(:attendee)
    cond do
       not is_nil(attendee)->
        Roulette.spin(attendee)
        conn
        |> put_status(:ok)
        |> json(%{message: "You spinned the roulette"})

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Only attendees can spin the roulette"})
    end
  end
end
