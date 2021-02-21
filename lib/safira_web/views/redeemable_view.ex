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

  def render("index_non_attendee.json", %{redeemables: redeemables}) do
    %{data: render_many(redeemables, RedeemableView, "non_attendee_redeemables.json")}
  end

  def render("show.json", %{redeemable: redeemable}) do
    %{data: render_one(redeemable, RedeemableView, "redeemables.json")}
  end

  def render("show_non_attendee.json", %{redeemable: redeemable}) do
    %{data: render_one(redeemable, RedeemableView, "non_attendee_redeemables.json")}
  end

  def render("redeemables.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      description: redeemable.description,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      stock: redeemable.stock,
      max_per_user: redeemable.max_per_user,
      can_buy: redeemable.can_buy
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

  def render("non_attendee_redeemables.json", %{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      description: redeemable.description,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      stock: redeemable.stock,
      max_per_user: redeemable.max_per_user,
      can_buy: 0
    }
  end
end
