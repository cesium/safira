defmodule Safira.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Inventory` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        redeemed: true,
        redeemed_at: ~N[2024-09-15 21:18:00]
      })
      |> Safira.Inventory.create_item()

    item
  end
end
