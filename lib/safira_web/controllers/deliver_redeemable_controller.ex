defmodule SafiraWeb.DeliverRedeemableController do
  use SafiraWeb, :controller

  alias Safira.Accounts

  alias Safira.Store

  alias Safira.Contest

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
  def create(conn, %{"redeem" => redeem_params}) do
    # checks the user token to see if its a manager
    if Accounts.is_manager(conn) do
      validate_redeem(conn, redeem_params)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Only managers can deliver redeemables"})
    end
  end

  def show(conn, %{"id" => attendee_id}) do
    attendee = Accounts.get_attendee!(attendee_id)

    if is_nil(attendee) do
      conn
      |> put_status(:bad_request)
      |> json(%{Error: "Wrong attendee"})
    else
      if Accounts.is_manager(conn) do
        redeemables = Store.get_attendee_not_redemed(attendee)
        render(conn, "index.json", delivers: redeemables)
      else
        redeemables = Store.get_attendee_redeemables(attendee)
        render(conn, "index.json", delivers: redeemables)
      end
    end
  end

  def validate_redeem(conn, json) do
    attendee =
      Map.get(json, "attendee_id")
      # fetch user by id
      |> Accounts.get_attendee()

    redeemable_id = Map.get(json, "redeemable")
    quant = Map.get(json, "quantity")

    case {attendee, Store.exist_redeemable(redeemable_id), quant} do
      {nil, _, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{User: "Attendee does not exist"})

      {_, false, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{Redeemable: "There is no such redeemable"})

      {_, _, nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{Redeemable: "Json does not have `quantity` param"})

      {_, _, _} ->
        case Store.redeem_redeemable(redeemable_id, attendee, quant) do
          {:ok, changes} ->
            conn
            |> put_status(:ok)
            |> json(%{Redeemable: "#{Map.get(changes, :redeemable).name} redeemed successfully!"})

          {:error, _error} ->
            conn
            |> put_status(:bad_request)
            |> json(%{Error: "Wrong quantity"})
        end
    end
  end
end
