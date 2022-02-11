defmodule SafiraWeb.PrizeView do
  use SafiraWeb, :view

  alias SafiraWeb.PrizeView
  alias Safira.Avatar

  def render("index.json", %{prizes: prizes}) do
    %{data: render_many(prizes, PrizeView, "prize_show.json")}
  end

  def render("show.json", %{prize: prize}) do
    %{data: render_one(prize, PrizeView, "prize_show.json")}
  end

  def render("prize.json", %{prize: prize}) do
    %{
      id: prize.id,
      name: prize.name,
      avatar: Avatar.url({prize.avatar, prize}, :original),
      not_redeemed: prize.not_redeemed
    }
  end

  def render("prize_show.json", %{prize: prize}) do
    %{
      id: prize.id,
      name: prize.name,
      avatar: Avatar.url({prize.avatar, prize}, :original),
      max_amount_per_attendee: prize.max_amount_per_attendee,
      stock: prize.stock
    }
  end
end
