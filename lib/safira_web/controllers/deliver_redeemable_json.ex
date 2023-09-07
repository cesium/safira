defmodule SafiraWeb.DeliverRedeemableJSON do
  @moduledoc false
  alias Safira.Avatar

  def index(%{delivers: delivers}) do
    %{data: for(d <- delivers, do: delivers_show(%{deliver_redeemable: d}))}
  end

  def delivers_show(%{deliver_redeemable: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: Avatar.url({deliver.img, deliver}, :original),
      not_redeemed: deliver.not_redeemed
    }
  end
end
