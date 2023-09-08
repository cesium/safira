defmodule SafiraWeb.RedeemableJSON do
  alias Safira.Avatar

  def index(%{redeemables: redeemables}) do
    %{data: for(r <- redeemables, do: redeemables(%{redeemable: r}))}
  end

  def index_my_redeemables(%{redeemables: redeemables}) do
    %{data: for(r <- redeemables, do: my_redeemables(%{redeemable: r}))}
  end

  def index_non_attendee(%{redeemables: redeemables}) do
    %{data: for(r <- redeemables, do: non_attendee_redeemables(%{redeemable: r}))}
  end

  def show(%{redeemable: redeemable}) do
    %{data: redeemables(%{redeemable: redeemable})}
  end

  def show_non_attendee(%{redeemable: redeemable}) do
    %{data: non_attendee_redeemables(%{redeemable: redeemable})}
  end

  def redeemables(%{redeemable: redeemable}) do
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

  def my_redeemables(%{redeemable: redeemable}) do
    %{
      id: redeemable.id,
      name: redeemable.name,
      image: Avatar.url({redeemable.img, redeemable}, :original),
      price: redeemable.price,
      quantity: redeemable.quantity,
      not_redeemed: redeemable.not_redeemed
    }
  end

  def non_attendee_redeemables(%{redeemable: redeemable}) do
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
