defmodule Safira.InventoryTest do
  use Safira.DataCase

  alias Safira.AccountsFixtures
  alias Safira.Inventory

  describe "items" do
    alias Safira.Inventory.Item

    import Safira.InventoryFixtures

    @invalid_attrs %{type: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Inventory.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Inventory.get_item!(item.id).id == item.id
    end

    test "create_item/1 with valid data creates a item" do
      attendee = AccountsFixtures.attendee_fixture()

      valid_attrs = %{
        type: :prize,
        attendee_id: attendee.id,
        redeemed_at: ~N[2024-09-15 21:18:00]
      }

      assert {:ok, %Item{} = item} = Inventory.create_item(valid_attrs)
      assert item.type == :prize
      assert item.attendee_id == attendee.id
      assert item.redeemed_at == ~N[2024-09-15 21:18:00]
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{redeemed_at: ~N[2024-09-16 21:18:00]}

      assert {:ok, %Item{} = item} = Inventory.update_item(item, update_attrs)
      assert item.redeemed_at == ~N[2024-09-16 21:18:00]
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_item(item, @invalid_attrs)
      assert item.id == Inventory.get_item!(item.id).id
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Inventory.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Inventory.change_item(item)
    end
  end
end
