defmodule SafiraWeb.DeliverPrizeController do
  use SafiraWeb, :controller

  alias Safira.Roulette
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

    # redeem params:
  @doc "
      json
  {
        redeem:{
          attendee_id: id
          redeemable: redeemable_id
          quantity: quantity
        }
  }

  "
  def create(conn , %{"redeem" => redeem_params}) do
    cond do
      Accounts.is_manager(conn) -> #checks the user toker to see if its a manager
        validate_redeem(conn, redeem_params)
      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Only managers can give prizes"})
    end
  end

  def show(conn, %{"id" => attendee_id}) do
    attendee =
      Accounts.get_attendee!(attendee_id)
      #I WAS HERE
    cond do
      not is_nil(attendee) ->
        prize = Roulette.get_attendee_not_redeemed(attendee)

        # conn
        # |> put_status(:bad_request)
        # |> json(%{Error: "TEST after after get attendee_not redeemed"})

        #temp comment
        render(conn, "indexe.json", delivers: prize)
      true ->
        conn
        |> put_status(:bad_request)
        |> json(%{Error: "Wrong attendee"})
    end
  end

  def validate_redeem(conn, json) do
    attendee =
      Map.get(json, "attendee_id")
      |> Accounts.get_attendee() #fetch user by id
    prize_id = Map.get(json, "prize")
    quant = Map.get(json, "quantity")
    exist = Roulette.exist_prize(prize_id)
    # I WAS HERE

    case {attendee, exist, quant} do
      {nil,_,_} ->
        conn
        |> put_status(:not_found)
        |> json(%{User: "Attendee does not exist"})
      {_,false,_} ->
        conn
        |> put_status(:not_found)
        |> json(%{Redeemable: "There is no such Prize"})
      {_,_,nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "Json does not have `quantity` param"})
      {_,_,_} ->
        #I WAS HERE
        rp = Roulette.redeem_prize(prize_id, attendee, quant)
        conn
        |> put_status(:bad_request)
        |> json(%{Error: "AFTER ROULETTE"})

        # case rp do
        #   {:ok, changes} ->
        #     conn
        #     |> put_status(:ok)
        #     |> json(%{Prize: "#{Map.get(changes, :prize).name} redeemed successfully!"})
        #   {:error, error} ->
        #     conn
        #     |> put_status(:bad_request)
        #     |> json(%{Error: "Wrong quantity"})
        # end
    end
  end

end
