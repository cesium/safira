defmodule SafiraWeb.RedeemableView do
  use SafiraWeb, :view
  alias SafiraWeb.RedeemableView
  alias Safira.Avatar

  def render("index.json", %{redeemables: redeemables}) do
    %{data: render_many(redeemables, RedeemableView, "redeemables.json")}
  end

  def render("show.json", %{redeemable: redeemable}) do
    %{data: render_one(redeemable, RedeemableView, "redeemable_show.json")}
  end

  def render("redeemables.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      description: redeemable.description,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      redeem_limit: redeemable.redeem_limit,
      max_per_user: redeemable.max_per_user
    }
  end

  def render("redeemable_show.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      description: redeemable.description,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      redeem_limit: redeemable.redeem_limit,
      max_per_user: redeemable.max_per_user
    }
  end
end
