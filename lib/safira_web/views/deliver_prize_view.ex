defmodule SafiraWeb.DeliverPrizeView do
  use SafiraWeb, :view
  alias SafiraWeb.DeliverPrizeView

  def render("index.json", %{delivers: delivers}) do
    %{data: render_many(delivers, DeliverPrizeView, "delivers.json")}
  end

  def render("delivers.json", %{deliver_prize: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: deliver.avatar,
      not_redeemed: deliver.not_redeemed
    }
  end
end
