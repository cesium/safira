defmodule SafiraWeb.ReferralView do
  use SafiraWeb, :view
  alias SafiraWeb.ReferralView

  def render("index.json", %{referrals: referrals}) do
    %{data: render_many(referrals, ReferralView, "referral.json")}
  end

  def render("show.json", %{referral: referral}) do
    %{data: render_one(referral, ReferralView, "referral.json")}
  end

  def render("referral.json", %{referral: referral}) do
    %{id: referral.id,
      available: referral.available}
  end
end
