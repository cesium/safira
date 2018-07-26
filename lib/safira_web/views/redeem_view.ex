defmodule SafiraWeb.RedeemView do
  use SafiraWeb, :view
  alias SafiraWeb.RedeemView

  def render("index.json", %{redeems: redeems}) do
    %{data: render_many(redeems, RedeemView, "redeem.json")}
  end

  def render("show.json", %{redeem: redeem}) do
    %{data: render_one(redeem, RedeemView, "redeem.json")}
  end

  def render("redeem.json", %{redeem: redeem}) do
    %{id: redeem.id}
  end
end
