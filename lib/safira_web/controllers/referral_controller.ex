defmodule SafiraWeb.ReferralController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Contest.Referral

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    referrals = Contest.list_referrals()
    render(conn, "index.json", referrals: referrals)
  end

  def create(conn, %{"referral" => referral_params}) do
    with {:ok, %Referral{} = referral} <- Contest.create_referral(referral_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", referral_path(conn, :show, referral))
      |> render("show.json", referral: referral)
    end
  end

  def show(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    render(conn, "show.json", referral: referral)
  end

  def update(conn, %{"id" => id, "referral" => referral_params}) do
    referral = Contest.get_referral!(id)

    with {:ok, %Referral{} = referral} <- Contest.update_referral(referral, referral_params) do
      render(conn, "show.json", referral: referral)
    end
  end

  def delete(conn, %{"id" => id}) do
    referral = Contest.get_referral!(id)
    with {:ok, %Referral{}} <- Contest.delete_referral(referral) do
      send_resp(conn, :no_content, "")
    end
  end
end
