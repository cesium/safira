defmodule SafiraWeb.DeliverRedeemableController do
  use SafiraWeb, :controller

  alias Safira.Store
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
        |> json(%{error: "Only managers can deliver redeemables"})
    end
  end

  def validate_redeem(conn, json) do
    attendee =
      Map.get(json, "attendee_id")
      |> Accounts.get_attendee() #fetch user by id
    redeemable_id = Map.get(json, "redeemable")
    quant = Map.get(json, "quantity")

    case {attendee,Store.exist_redeemable(redeemable_id),quant} do
      {nil,_,_} ->
        conn
        |> put_status(:not_found)
        |> json(%{User: "Attendee does not exist"})
      {_,false,_} ->
        conn
        |> put_status(:not_found)
        |> json(%{Redeemable: "There is no such redeemable"})
      {_,_,nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "Json does not have `quantity` param"})
      {_,_,_} ->
        case Store.redeem_redeemable(redeemable_id, attendee, quant) do
          {:ok, changes} -> 
            conn
              |> put_status(:ok)
              |> json(%{Redeemable: "#{Map.get(changes, :redeemable).name} redeemed successfully!"})
          {:error, error} -> 
            conn
              |> put_status(:bad_request)
              |> json(%{Error: "Wrong quantity"})
        end
    end
  end
end