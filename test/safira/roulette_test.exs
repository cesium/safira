defmodule Safira.RouletteTest do
  use Safira.DataCase

  alias Safira.Roulette

  describe "prizes" do
    alias Safira.Roulette.Prize

    @valid_attrs %{max_amount_per_attendee: 10, name: "some name", probability: 0.42, stock: 40}
    @update_attrs %{max_amount_per_attendee: 10, name: "some updated name", probability: 0.61, stock: 50}
    @invalid_attrs1 %{max_amount_per_attendee: nil, name: nil, probability: nil, stock: nil}
    @invalid_attrs2 %{max_amount_per_attendee: 11, name: "some name", probability: 0.42, stock: 10}
    @invalid_attrs3 %{max_amount_per_attendee: 9, name: "some name", probability: -0.7, stock: 10}
    @invalid_attrs4 %{max_amount_per_attendee: 9, name: "some name", probability: 1.7, stock: 10}

    def prize_fixture(attrs \\ %{}) do
      {:ok, prize} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Roulette.create_prize()

      prize
    end

    test "list_prizes/0 returns all prizes" do
      prize = prize_fixture()
      assert Roulette.list_prizes() == [prize]
    end

    test "get_prize!/1 returns the prize with given id" do
      prize = prize_fixture()
      assert Roulette.get_prize!(prize.id) == prize
    end

    test "create_prize/1 with valid data creates a prize" do
      assert {:ok, %Prize{} = prize} = Roulette.create_prize(@valid_attrs)
      assert prize.max_amount_per_attendee == 10
      assert prize.name == "some name"
      assert prize.probability == 0.42
      assert prize.stock == 40
    end

    test "create_prize/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roulette.create_prize(@invalid_attrs1)
      assert {:error, %Ecto.Changeset{}} = Roulette.create_prize(@invalid_attrs2)
      assert {:error, %Ecto.Changeset{}} = Roulette.create_prize(@invalid_attrs3)
      assert {:error, %Ecto.Changeset{}} = Roulette.create_prize(@invalid_attrs4)
    end

    test "update_prize/2 with valid data updates the prize" do
      prize = prize_fixture()
      assert {:ok, prize} = Roulette.update_prize(prize, @update_attrs)
      assert %Prize{} = prize
      assert prize.max_amount_per_attendee == 10
      assert prize.name == "some updated name"
      assert prize.probability == 0.61
      assert prize.stock == 50
    end

    test "update_prize/2 with invalid data returns error changeset" do
      prize = prize_fixture()
      assert {:error, %Ecto.Changeset{}} = Roulette.update_prize(prize, @invalid_attrs1)
      assert prize == Roulette.get_prize!(prize.id)
      assert {:error, %Ecto.Changeset{}} = Roulette.update_prize(prize, @invalid_attrs2)
      assert prize == Roulette.get_prize!(prize.id)
      assert {:error, %Ecto.Changeset{}} = Roulette.update_prize(prize, @invalid_attrs3)
      assert prize == Roulette.get_prize!(prize.id)
      assert {:error, %Ecto.Changeset{}} = Roulette.update_prize(prize, @invalid_attrs4)
      assert prize == Roulette.get_prize!(prize.id)
    end

    test "delete_prize/1 deletes the prize" do
      prize = prize_fixture()
      assert {:ok, %Prize{}} = Roulette.delete_prize(prize)
      assert_raise Ecto.NoResultsError, fn -> Roulette.get_prize!(prize.id) end
    end

    test "change_prize/1 returns a prize changeset" do
      prize = prize_fixture()
      assert %Ecto.Changeset{} = Roulette.change_prize(prize)
    end
  end
end
