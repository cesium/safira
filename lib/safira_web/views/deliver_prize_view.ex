defmodule SafiraWeb.DeliverPrizeView do
  use SafiraWeb, :view

  alias Safira.Avatar

  alias SafiraWeb.DeliverPrizeView

  def render("index.json", %{delivers: delivers}) do
    %{data: render_many(delivers, DeliverPrizeView, "delivers.json")}
  end

  def render("delivers.json", %{deliver_prize: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: Avatar.url({deliver.avatar, deliver}, :original),
      not_redeemed: deliver.not_redeemed
    }
  end
end
