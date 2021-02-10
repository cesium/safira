defmodule Safira.RouletteTest do
  use Safira.DataCase

  alias Safira.Roulette

  describe "prizes" do
    alias Safira.Roulette.Prize

    @valid_attrs %{max_amount_per_attendee: 10, name: "some name", probability: 0.42, stock: 40}
    @update_attrs %{
      max_amount_per_attendee: 10,
      name: "some updated name",
      probability: 0.61,
      stock: 50
    }
    @invalid_attrs1 %{max_amount_per_attendee: nil, name: nil, probability: nil, stock: nil}
    @invalid_attrs2 %{
      max_amount_per_attendee: 11,
      name: "some name",
      probability: 0.42,
      stock: 10
    }
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

  describe "attendees_prizes" do
    alias Safira.Roulette.AttendeePrize

    @invalid_attrs %{attendee_id: nil, prize_id: nil, quantity: nil}

    def setup() do
      user = create_user_strategy(:user)
      attendee = build(:attendee) |> Map.put(:user_id, user.id) |> insert
      prize = create_prize_strategy(:prize)
      {attendee, prize}
    end

    def attendee_prize_fixture(attrs \\ %{}) do
      {attendee, prize} = setup()
      attendee_prize = %{attendee_id: attendee.id, prize_id: prize.id, quantity: 1}

      {:ok, returned_attendee_prize} =
        attrs
        |> Enum.into(attendee_prize)
        |> Roulette.create_attendee_prize()

      returned_attendee_prize
    end

    test "list_attendees_prizes/0 returns all attendees_prizes" do
      attendee_prize = attendee_prize_fixture()
      assert Roulette.list_attendees_prizes() == [attendee_prize]
    end

    test "get_attendee_prize!/1 returns the attendee_prize with given id" do
      attendee_prize = attendee_prize_fixture()
      assert Roulette.get_attendee_prize!(attendee_prize.id) == attendee_prize
    end

    test "create_attendee_prize/1 with valid data creates a attendee_prize" do
      {attendee, prize} = setup()
      attendee_prize = %{attendee_id: attendee.id, prize_id: prize.id, quantity: 1}

      assert {:ok, %AttendeePrize{} = returned_attendee_prize} =
               Roulette.create_attendee_prize(attendee_prize)

      assert returned_attendee_prize.attendee_id == attendee.id
      assert returned_attendee_prize.prize_id == prize.id
      assert returned_attendee_prize.quantity == 1
    end

    test "create_attendee_prize/1 with invalid data returns error changeset" do
      {attendee, prize} = setup()
      # nil values
      assert {:error, %Ecto.Changeset{}} = Roulette.create_attendee_prize(@invalid_attrs)
      # quantity 0
      attendee_prize = %{attendee_id: attendee.id, prize_id: prize.id, quantity: 0}
      assert {:error, %Ecto.Changeset{}} = Roulette.create_attendee_prize(attendee_prize)
      # prize nil
      attendee_prize = %{attendee_id: attendee.id, prize_id: nil, quantity: 1}
      assert {:error, %Ecto.Changeset{}} = Roulette.create_attendee_prize(attendee_prize)
      # attendee nil
      attendee_prize = %{attendee_id: nil, prize_id: prize.id, quantity: 1}
      assert {:error, %Ecto.Changeset{}} = Roulette.create_attendee_prize(attendee_prize)
    end

    test "update_attendee_prize/2 with valid data updates the attendee_prize" do
      attendee_prize = attendee_prize_fixture()

      assert {:ok, attendee_prize} =
               Roulette.update_attendee_prize(attendee_prize, %{quantity: 5})

      assert %AttendeePrize{} = attendee_prize
      assert attendee_prize.quantity == 5
    end

    test "update_attendee_prize/2 with invalid data returns error changeset" do
      attendee_prize = attendee_prize_fixture()
      # invalid quantity
      assert {:error, %Ecto.Changeset{}} =
               Roulette.update_attendee_prize(attendee_prize, %{quantity: 0})

      assert attendee_prize == Roulette.get_attendee_prize!(attendee_prize.id)
      # invalid attendee_id
      assert {:error, %Ecto.Changeset{}} =
               Roulette.update_attendee_prize(attendee_prize, %{attendee_id: nil})

      assert attendee_prize == Roulette.get_attendee_prize!(attendee_prize.id)
      # invalid prize_id
      assert {:error, %Ecto.Changeset{}} =
               Roulette.update_attendee_prize(attendee_prize, %{prize_id: nil})

      assert attendee_prize == Roulette.get_attendee_prize!(attendee_prize.id)
    end

    test "delete_attendee_prize/1 deletes the attendee_prize" do
      attendee_prize = attendee_prize_fixture()
      assert {:ok, %AttendeePrize{}} = Roulette.delete_attendee_prize(attendee_prize)
      assert_raise Ecto.NoResultsError, fn -> Roulette.get_attendee_prize!(attendee_prize.id) end
    end

    test "change_attendee_prize/1 returns a attendee_prize changeset" do
      attendee_prize = attendee_prize_fixture()
      assert %Ecto.Changeset{} = Roulette.change_attendee_prize(attendee_prize)
    end
  end
end
