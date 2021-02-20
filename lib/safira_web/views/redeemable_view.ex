defmodule SafiraWeb.RedeemableView do
  use SafiraWeb, :view
  alias SafiraWeb.RedeemableView
  alias Safira.Avatar

  def render("index.json", %{redeemables: redeemables}) do
    %{data: render_many(redeemables, RedeemableView, "redeemables.json")}
  end

  def render("index_my_redeemables.json", %{redeemables: redeemables}) do
    %{data: render_many(redeemables, RedeemableView, "my_redeemables.json")}
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
      stock: redeemable.stock,
      max_per_user: redeemable.max_per_user
    }
  end

  def render("my_redeemables.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      quantity: redeemable.quantity
    }
  end

  def render("redeemable_show.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      description: redeemable.description,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      stock: redeemable.stock,
      max_per_user: redeemable.max_per_user
    }
  end
end
