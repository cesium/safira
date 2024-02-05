defmodule Safira.SlotsTest do
  use Safira.DataCase
  alias Safira.Slots

  describe "payouts" do
    alias Safira.Slots.Payout

    @valid_attrs %{
      multiplier: 10.0,
      probability: 0.42
    }

    @invalid_attrs1 %{
      multiplier: -1.0,
      probability: 0.42
    }

    @invalid_attrs2 %{
      multiplier: 10.0,
      probability: 2.0
    }

    @invalid_attrs3 %{
      multiplier: 10.0,
      probability: -2.0
    }

    test "create_payout/1 with valid data creates a payout" do
      assert {:ok, %Payout{} = payout} = Slots.create_payout(@valid_attrs)
      assert payout.multiplier == 10.0
      assert payout.probability == 0.42
    end

    test "create_payout/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Slots.create_payout(@invalid_attrs1)
      assert {:error, %Ecto.Changeset{}} = Slots.create_payout(@invalid_attrs2)
      assert {:error, %Ecto.Changeset{}} = Slots.create_payout(@invalid_attrs3)
    end
  end
end
