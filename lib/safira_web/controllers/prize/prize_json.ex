defmodule SafiraWeb.PrizeJSON do
  @moduledoc false

  alias Safira.Avatar

  def index(%{prizes: prizes}) do
    %{data: for(p <- prizes, do: prize_show(%{prize: p}))}
  end

  def show(%{prize: prize}) do
    %{data: prize_show(%{prize: prize})}
  end

  def prize(%{prize: prize}) do
    %{
      id: prize.id,
      name: prize.name,
      avatar: Avatar.url({prize.avatar, prize}, :original)
    }
  end

  def prize_attendee(%{prize: prize}) do
    %{
      id: prize.id,
      name: prize.name,
      avatar: Avatar.url({prize.avatar, prize}, :original),
      not_redeemed: prize.not_redeemed,
      is_redeemable: prize.is_redeemable
    }
  end

  def prize_show(%{prize: prize}) do
    %{
      id: prize.id,
      name: prize.name,
      avatar: Avatar.url({prize.avatar, prize}, :original),
      max_amount_per_attendee: prize.max_amount_per_attendee,
      stock: prize.stock
    }
  end
end
