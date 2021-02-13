defmodule SafiraWeb.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Accounts
  alias Safira.Accounts.User

  action_fallback SafiraWeb.FallbackController

  def create(conn, %{"redeem" => redeem_params}) do
    user = Accounts.get_user(conn)

    cond do
      Accounts.is_company(conn) ->
        company_aux(conn, redeem_params, user)

      Accounts.is_manager(conn) ->
        manager_aux(conn, redeem_params, user)

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
        |> halt()
    end
  end

  defp company_aux(conn, redeem_params, user) do
    redeem_params = Map.put(redeem_params, "badge_id", user.company.badge_id)

    with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
      conn
      |> put_status(:created)
      |> json(%{redeem: "Badge redeemed successfully. Tokens added to your balance"})
    end
  end

  defp manager_aux(conn, redeem_params, user) do
    case Map.fetch(redeem_params, "badge_id") do
      {:ok, id} ->
        Contest.get_badge!(id)
        redeem_params = Map.put(redeem_params, "manager_id", user.manager.id)

        with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
          conn
          |> put_status(:created)
          |> json(%{redeem: "Badge redeemed successfully. Tokens added to your balance"})
        end

      _ ->
        {:error, :not_found}
    end
  end
end
