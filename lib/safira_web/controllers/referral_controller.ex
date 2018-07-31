defmodule SafiraWeb.ReferralController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Contest
  alias Safira.Contest.Redeem


  action_fallback SafiraWeb.FallbackController

  plug Safira.Authorize, :attendee

  def show(conn, %{"id" => id}) do
    referral = Contest.preload_referral(id)
    case referral.available do
      true ->
        user = get_user(conn)
        redeem_params = %{badge_id: referral.badge_id, attendee_id: user.attendee.id}
        with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
          Contest.update_referral(referral,%{available: false})
          conn
          |> put_status(:created)
          |> json(%{referral: "Referral redeemed successfully"})
        end
      _ ->
          conn
          |> put_status(:unauthorized)
          |> json(%{referral: "Referral not available"})
    end
  end

  defp get_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> Accounts.get_user_preload!()
    end
  end
end
