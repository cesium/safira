defmodule SafiraWeb.DeliverRedeemableView do
  use SafiraWeb, :view
  alias SafiraWeb.DeliverRedeemableView

  def render("index.json", %{delivers: delivers}) do
    %{data: render_many(delivers, DeliverRedeemableView, "deliver.json")}
  end

  def render("deliver.json", %{deliver: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: deliver.img,
      not_redeemed: deliver.not_redeemed
    }
  end
end