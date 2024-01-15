defmodule SafiraWeb.DeliverPrizeJSON do
  @moduledoc false

  alias Safira.Avatar

  def index(%{delivers: delivers}) do
    %{data: for(d <- delivers, do: delivers(%{deliver_prize: d}))}
  end

  def delivers(%{deliver_prize: deliver}) do
    %{
      id: deliver.id,
      name: deliver.name,
      image: Avatar.url({deliver.avatar, deliver}, :original),
      not_redeemed: deliver.not_redeemed
    }
  end
end
