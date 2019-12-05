defmodule SafiraWeb.RedeemController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Accounts
  alias Safira.Accounts.User

  action_fallback SafiraWeb.FallbackController

  def create(conn, %{"redeem" => redeem_params}) do
    user = get_user(conn)
    cond do
        is_company(conn) ->
            company_aux(conn,redeem_params,user)
        is_manager(conn) ->
            manager_aux(conn,redeem_params,user)
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
            |> json(%{redeem: "Badge redeem successfully"})
      end
  end

  defp manager_aux(conn, redeem_params, user)do
      case Map.fetch(redeem_params, "badge_id") do
        {:ok, id} ->
          Contest.get_badge!(id)
          redeem_params = Map.put(redeem_params, "manager_id", user.manager.id)
          with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
            conn
            |> put_status(:created)
            |> json(%{redeem: "Badge redeem successfully"})
          end
        _ ->
          {:error, :not_found}
      end
  end

  defp is_company(conn) do
    get_user(conn)
    |> Map.fetch!(:company)
    |> is_nil
    |> Kernel.not
  end

  defp is_manager(conn) do
    get_user(conn)
    |> Map.fetch!(:manager)
    |> is_nil
    |> Kernel.not
  end

  defp get_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> Accounts.get_user_preload!()
    end
  end
end
