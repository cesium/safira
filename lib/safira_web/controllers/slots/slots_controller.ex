defmodule SafiraWeb.SlotsController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Slots

  action_fallback SafiraWeb.FallbackController

  def spin(conn, %{"bet" => bet}) do
    attendee = Accounts.get_user(conn) |> Map.fetch!(:attendee)

    if is_nil(attendee) do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Only attendees can play the slots"})
    else
      case Integer.parse(bet) do
        {bet, ""} ->
          if bet > 0 do
            case Slots.spin(attendee, bet) do
              {:ok, outcome} ->
                render(conn, :spin_result, outcome)

              {:error, :not_enough_tokens} ->
                conn
                |> put_status(:unauthorized)
                |> json(%{error: "Insufficient token balance"})
            end
          else
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Bet should be a positive integer"})
          end

        _ ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Bet should be an integer"})
      end
    end
  end
end
