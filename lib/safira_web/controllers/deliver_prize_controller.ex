defmodule SafiraWeb.DeliverPrizeController do
  use SafiraWeb, :controller

  alias Safira.Accounts

  alias Safira.Roulette

  alias Safira.Contest

  action_fallback SafiraWeb.FallbackController

  # redeem params:
  @doc "
      json
  {
        redeem:{
          attendee_id: id
          prize: prize_id
          quantity: quantity
        }
  }

  "
  def create(conn, %{"redeem" => redeem_params}) do
    # checks the user token to see if its a manager
    if Accounts.is_manager(conn) do
      validate_redeem(conn, redeem_params)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Only managers can give prizes"})
    end
  end

  def show(conn, %{"id" => attendee_id}) do
    attendee = Accounts.get_attendee!(attendee_id)

    if is_nil(attendee) do
      conn
      |> put_status(:bad_request)
      |> json(%{Error: "Wrong attendee"})
    else
      prize = Roulette.get_attendee_not_redeemed(attendee)
      render(conn, "index.json", delivers: prize)
    end
  end

  def delete(conn, %{"badge_id" => badge_id, "user_id" => user_id}) do
    if Accounts.is_admin(conn) do
      badge = Contest.get_keys_redeem(user_id, badge_id)

      if badge != nil do
        Contest.delete_redeem(badge)
      else
        conn
        |> put_status(:bad_request)
        |> json(%{Error: "Badge doesn not exist"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Only admins can remove prizes"})
    end
  end

  def validate_redeem(conn, json) do
    attendee =
      Map.get(json, "attendee_id")
      # fetch user by id
      |> Accounts.get_attendee()

    prize_id = Map.get(json, "prize")
    quant = Map.get(json, "quantity")
    exist = Roulette.exist_prize(prize_id)

    case {attendee, exist, quant} do
      {nil, _, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{User: "Attendee does not exist"})

      {_, false, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{Redeemable: "There is no such Prize"})

      {_, _, nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "Json does not have `quantity` param"})

      {_, _, _} ->
        rp = Roulette.redeem_prize(prize_id, attendee, quant)

        case rp do
          {:ok, changes} ->
            conn
            |> put_status(:ok)
            |> json(%{Prize: "#{Map.get(changes, :prizes).name} redeemed successfully!"})

          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{Error: "Wrong quantity"})
        end
    end
  end
end
