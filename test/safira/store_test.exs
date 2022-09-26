defmodule Safira.StoreTest do
  use Safira.DataCase

  alias Safira.Store

  describe "list_redeemables/0" do
    test "No redeemables" do
      assert Store.list_redeemables() == []
    end

    test "Multiple redeemables" do
      r1 = insert(:redeemable)
      r2 = insert(:redeemable)

      assert Store.list_redeemables() == [r1, r2]
    end
  end

  describe "get_redeemable!/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Store.get_redeemable!(nil)
      end
    end

    test "Wrong id" do
      r1 = insert(:redeemable)

      assert_raise Ecto.NoResultsError, fn ->
        Store.get_redeemable!(r1.id + 1)
      end
    end

    test "Exists" do
      r1 = insert(:redeemable)

      assert Store.get_redeemable!(r1.id) == r1
    end
  end

  describe "exist_redeemable/1" do
    test "Nil" do
      assert not Store.exist_redeemable(nil)
    end

    test "Wrong id" do
      r1 = insert(:redeemable)

      assert not Store.exist_redeemable(r1.id + 1)
    end

    test "Exists" do
      r1 = insert(:redeemable)

      assert Store.exist_redeemable(r1.id)
    end
  end

  describe "list_store_redeemables/1" do
    test "No redeemables" do
      at = insert(:attendee)
      assert Store.list_store_redeemables(at) == []
    end

    test "Multiple redeemables" do
      at = insert(:attendee)
      r1 = insert(:redeemable, is_redeemable: true)
      r1 = r1
      |> Map.put(:can_buy, Kernel.min(r1.stock, r1.max_per_user))
      r2 = insert(:redeemable, is_redeemable: true, stock: 0)
      |> Map.put(:can_buy, 0)
      r3 = insert(:redeemable, is_redeemable: false)

      assert Store.list_store_redeemables(at) == [r1, r2]
    end
  end

  describe "get_redeemable_attendee/2" do
    test "Nil redeemable" do
      at = insert(:attendee)
      assert_raise ArgumentError, fn ->
        Store.get_redeemable_attendee(nil, at.id)
      end
    end

    test "No redeemable" do
      at = insert(:attendee)
      assert_raise Ecto.NoResultsError, fn ->
        Store.get_redeemable_attendee(42, at.id)
      end
    end

    test "Redeemable exists" do
      at = insert(:attendee)
      r1 = insert(:redeemable, is_redeemable: true)
      r1 = r1
      |> Map.put(:can_buy, Kernel.min(r1.stock, r1.max_per_user))

      assert Store.get_redeemable_attendee(r1.id, at) == r1
    end
  end

  describe "create_redeemable/1" do
    test "Valid data" do
      {:ok, r1} = Store.create_redeemable(params_for(:redeemable))
      assert Store.list_redeemables() == [r1]
    end

    test "Invalid data" do
      {:error, changeset} = Store.create_redeemable(params_for(:redeemable, max_per_user: -1))
      assert Store.list_redeemables() == []
    end
  end

  describe "update_redeemable/2" do
    test "Valid data" do
      r1 = insert(:redeemable)
      {:ok, r2} = Store.update_redeemable(r1, params_for(:redeemable))
      assert Store.list_redeemables() == [r2]
    end

    test "Invalid data" do
      r1 = insert(:redeemable)
      {:error, changeset} = Store.update_redeemable(r1, params_for(:redeemable, max_per_user: -1))
      assert Store.list_redeemables() == [r1]
    end
  end

  describe "buy_redeemable/2" do
    test "Attendee with enough tokens" do
      r1 = insert(:redeemable, price: 0)
      at = insert(:attendee)
      {:ok, _data} = Store.buy_redeemable(r1.id, at)
    end

    test "Attendee without enough tokens" do
      r1 = insert(:redeemable)
      at = insert(:attendee)
      {:error, :attendee, _changeset, _data} = Store.buy_redeemable(r1.id, at)
    end

    test "Out of stock" do
      r1 = insert(:redeemable, stock: 0)
      at = insert(:attendee)
      {:error, :redeemable, _changeset, _data} = Store.buy_redeemable(r1.id, at)
    end
  end

  describe "redeem_redeemable/3" do
    test "Right amount" do
      r1 = insert(:redeemable, price: 0)
      at = insert(:attendee)
      {:ok, _data} = Store.buy_redeemable(r1.id, at)

      {:ok, _data} = Store.redeem_redeemable(r1.id, at, 1)
    end

    test "Too many" do
      r1 = insert(:redeemable, price: 0)
      at = insert(:attendee)
      {:ok, _data} = Store.buy_redeemable(r1.id, at)

      {:error, :update_buy, _changeset, _data} = Store.redeem_redeemable(r1.id, at, 2)
    end

    test "Did not buy" do
      r1 = insert(:redeemable, stock: 0)
      at = insert(:attendee)

      {:error, :buy, nil, %{}} = Store.redeem_redeemable(r1.id, at, 1)
    end
  end

  describe "get_attendee_redeemables/1" do
    test "Returns all redeemables" do
      r1 = insert(:redeemable, price: 0)
      r2 = insert(:redeemable, price: 0)
      at = insert(:attendee)
      {:ok, _data} = Store.buy_redeemable(r1.id, at)
      {:ok, _data} = Store.buy_redeemable(r2.id, at)
      {:ok, _data} = Store.redeem_redeemable(r1.id, at, 1)

      r1 = r1
      |> Map.put(:not_redeemed, 0)
      |> Map.put(:quantity, 1)
      |> Map.put(:stock, r1.stock - 1)

      r2 = r2
      |> Map.put(:not_redeemed, 1)
      |> Map.put(:quantity, 1)
      |> Map.put(:stock, r2.stock - 1)

      assert [r1, r2] == Store.get_attendee_redeemables(at)
      |> Enum.sort_by(fn x -> x.id end)
    end
  end

  describe "get_attendee_not_redeemed/1" do
    test "Returns all not redeemed" do
      r1 = insert(:redeemable, price: 0)
      r2 = insert(:redeemable, price: 0)
      at = insert(:attendee)
      {:ok, _data} = Store.buy_redeemable(r1.id, at)
      {:ok, _data} = Store.buy_redeemable(r2.id, at)
      {:ok, _data} = Store.redeem_redeemable(r1.id, at, 1)

      r2 = r2
      |> Map.put(:not_redeemed, 1)
      |> Map.put(:quantity, 1)
      |> Map.put(:stock, r2.stock - 1)

      assert [r2] == Store.get_attendee_not_redemed(at)
    end
  end
end
