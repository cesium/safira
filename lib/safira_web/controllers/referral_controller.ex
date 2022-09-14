defmodule SafiraWeb.ReferralController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Contest
  alias Safira.Contest.Redeem

  action_fallback SafiraWeb.FallbackController

  plug Safira.Authorize, :attendee

  def create(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    case referral.available do
      true ->
        user = Accounts.get_user(conn)
        redeem_params = %{badge_id: referral.badge_id, attendee_id: user.attendee.id}
        with {:ok, %Redeem{} = _redeem} <- Contest.create_redeem(redeem_params) do
          Contest.update_referral(referral, %{available: false, attendee_id: user.attendee.id})
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
end
