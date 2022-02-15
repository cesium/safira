defmodule SafiraWeb.DeliverRedeemableView do
  use SafiraWeb, :view
  alias SafiraWeb.DeliverRedeemableView

  def render("index.json", %{delivers: delivers}) do
    %{data: render_many(delivers, DeliverRedeemableView, "delivers.json")}
  end

  def render("delivers.json", %{deliver_redeemable: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: Avatar.url({deliver.img, deliver}, :original),
      not_redeemed: deliver.not_redeemed
    }
  end
end
