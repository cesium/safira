defmodule Safira.MinigamesTest do
  use Safira.DataCase

  alias Safira.Minigames

  describe "prizes" do
    alias Safira.Minigames.Prize

    import Safira.MinigamesFixtures

    @invalid_attrs %{name: nil, stock: nil}

    test "list_prizes/0 returns all prizes" do
      prize = prize_fixture()
      assert Minigames.list_prizes() == [prize]
    end

    test "get_prize!/1 returns the prize with given id" do
      prize = prize_fixture()
      assert Minigames.get_prize!(prize.id) == prize
    end

    test "create_prize/1 with valid data creates a prize" do
      valid_attrs = %{name: "some name", stock: 42}

      assert {:ok, %Prize{} = prize} = Minigames.create_prize(valid_attrs)
      assert prize.name == "some name"
      assert prize.stock == 42
    end

    test "create_prize/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_prize(@invalid_attrs)
    end

    test "update_prize/2 with valid data updates the prize" do
      prize = prize_fixture()
      update_attrs = %{name: "some updated name", stock: 43}

      assert {:ok, %Prize{} = prize} = Minigames.update_prize(prize, update_attrs)
      assert prize.name == "some updated name"
      assert prize.stock == 43
    end

    test "update_prize/2 with invalid data returns error changeset" do
      prize = prize_fixture()
      assert {:error, %Ecto.Changeset{}} = Minigames.update_prize(prize, @invalid_attrs)
      assert prize == Minigames.get_prize!(prize.id)
    end

    test "delete_prize/1 deletes the prize" do
      prize = prize_fixture()
      assert {:ok, %Prize{}} = Minigames.delete_prize(prize)
      assert_raise Ecto.NoResultsError, fn -> Minigames.get_prize!(prize.id) end
    end

    test "change_prize/1 returns a prize changeset" do
      prize = prize_fixture()
      assert %Ecto.Changeset{} = Minigames.change_prize(prize)
    end
  end

  describe "wheel_drops" do
    alias Safira.Minigames.WheelDrop

    import Safira.MinigamesFixtures

    @invalid_attrs %{probability: nil, max_per_attendee: nil}

    test "list_wheel_drops/0 returns all wheel_drops" do
      wheel_drop = wheel_drop_fixture()
      assert Minigames.list_wheel_drops() == [wheel_drop]
    end

    test "get_wheel_drop!/1 returns the wheel_drop with given id" do
      wheel_drop = wheel_drop_fixture()
      assert Minigames.get_wheel_drop!(wheel_drop.id) == wheel_drop
    end

    test "create_wheel_drop/1 with valid data creates a wheel_drop" do
      valid_attrs = %{probability: 0.2, max_per_attendee: 42}

      assert {:ok, %WheelDrop{} = wheel_drop} = Minigames.create_wheel_drop(valid_attrs)
      assert wheel_drop.probability == 0.2
      assert wheel_drop.max_per_attendee == 42
    end

    test "create_wheel_drop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_wheel_drop(@invalid_attrs)
    end

    test "update_wheel_drop/2 with valid data updates the wheel_drop" do
      wheel_drop = wheel_drop_fixture()
      update_attrs = %{probability: 0.2, max_per_attendee: 43}

      assert {:ok, %WheelDrop{} = wheel_drop} =
               Minigames.update_wheel_drop(wheel_drop, update_attrs)

      assert wheel_drop.probability == 0.2
      assert wheel_drop.max_per_attendee == 43
    end

    test "update_wheel_drop/2 with invalid data returns error changeset" do
      wheel_drop = wheel_drop_fixture()
      assert {:error, %Ecto.Changeset{}} = Minigames.update_wheel_drop(wheel_drop, @invalid_attrs)
      assert wheel_drop == Minigames.get_wheel_drop!(wheel_drop.id)
    end

    test "delete_wheel_drop/1 deletes the wheel_drop" do
      wheel_drop = wheel_drop_fixture()
      assert {:ok, %WheelDrop{}} = Minigames.delete_wheel_drop(wheel_drop)
      assert_raise Ecto.NoResultsError, fn -> Minigames.get_wheel_drop!(wheel_drop.id) end
    end

    test "change_wheel_drop/1 returns a wheel_drop changeset" do
      wheel_drop = wheel_drop_fixture()
      assert %Ecto.Changeset{} = Minigames.change_wheel_drop(wheel_drop)
    end
  end

  describe "coin_flip_game" do
    alias Safira.Accounts
    alias Safira.Minigames.CoinFlipRoom

    import Safira.AccountsFixtures

    setup do
      # Set up test users and enable the game
      player1 = attendee_fixture(%{tokens: 100})
      player2 = attendee_fixture(%{tokens: 100})
      Minigames.change_coin_flip_active(true)

      %{player1: player1, player2: player2}
    end

    test "creates room with valid bet", %{player1: player1} do
      attrs = %{"attendee_id" => player1.id, "bet" => 50}

      assert {:ok, %CoinFlipRoom{} = room} = Minigames.create_coin_flip_room(attrs)
      assert room.bet == 50
      assert room.player1_id == player1.id
      assert is_nil(room.player2_id)
      assert is_nil(room.result)
      assert room.finished == false

      # Check player1's tokens were deducted
      player1 = Accounts.get_attendee!(player1.id)
      assert player1.tokens == 50
    end

    test "cannot create room with insufficient tokens", %{player1: player1} do
      attrs = %{"attendee_id" => player1.id, "bet" => 150}

      assert {:error, _} = Minigames.create_coin_flip_room(attrs)
      # Tokens should not change
      player1 = Accounts.get_attendee!(player1.id)
      assert player1.tokens == 100
    end

    test "cannot create multiple rooms", %{player1: player1} do
      {:ok, _room} =
        Minigames.create_coin_flip_room(%{
          "attendee_id" => player1.id,
          "bet" => 50
        })

      assert {:error, "You already have an active game."} =
               Minigames.create_coin_flip_room(%{
                 "attendee_id" => player1.id,
                 "bet" => 50
               })
    end

    test "cannot join room when there is an existing room", %{player1: player1, player2: player2} do
      {:ok, _room} =
        Minigames.create_coin_flip_room(%{
          "attendee_id" => player1.id,
          "bet" => 50
        })

      {:ok, room2} =
        Minigames.create_coin_flip_room(%{
          "attendee_id" => player2.id,
          "bet" => 50
        })

      assert {:error, "You already have an active game."} =
               Minigames.join_coin_flip_room(room2.id, player1)
    end

    test "joining room starts game", %{player1: player1, player2: player2} do
      {:ok, room} =
        Minigames.create_coin_flip_room(%{
          "attendee_id" => player1.id,
          "bet" => 50
        })

      assert {:ok, updated_room} = Minigames.join_coin_flip_room(room.id, player2)
      assert updated_room.player2_id == player2.id
      assert updated_room.result in ["heads", "tails"]
      assert updated_room.finished == false

      # Check if room in database is finished
      room = Minigames.get_coin_flip_room!(room.id)
      assert room.finished == true

      # Check final token amounts
      player1 = Accounts.get_attendee!(player1.id)
      player2 = Accounts.get_attendee!(player2.id)

      case updated_room.result do
        "heads" ->
          # Won
          assert player1.tokens == 150
          # Lost
          assert player2.tokens == 50

        "tails" ->
          # Lost
          assert player1.tokens == 50
          # Won
          assert player2.tokens == 150
      end
    end

    test "cannot join full room", %{player1: player1, player2: player2} do
      player3 = attendee_fixture(%{tokens: 100})

      {:ok, room} =
        Minigames.create_coin_flip_room(%{
          "attendee_id" => player1.id,
          "bet" => 50
        })

      {:ok, _} = Minigames.join_coin_flip_room(room.id, player2)

      assert {:error, "The room is already full."} =
               Minigames.join_coin_flip_room(room.id, player3)
    end

    test "cannot create room when game is disabled", %{player1: player1} do
      Minigames.change_coin_flip_active(false)

      attrs = %{"attendee_id" => player1.id, "bet" => 50}

      assert {:error, "The coin flip game is not active."} =
               Minigames.create_coin_flip_room(attrs)
    end
  end

  describe "slots_reel_icons" do
    alias Safira.Minigames.SlotsReelIcon

    import Safira.MinigamesFixtures

    @invalid_attrs %{image: nil, reel_0_index: nil, reel_1_index: nil, reel_2_index: nil}

    test "list_slots_reel_icons/0 returns all slots_reel_icons" do
      slots_reel_icon = slots_reel_icon_fixture()
      assert Minigames.list_slots_reel_icons() == [slots_reel_icon]
    end

    test "get_slots_reel_icon!/1 returns the slots_reel_icon with given id" do
      slots_reel_icon = slots_reel_icon_fixture()
      assert Minigames.get_slots_reel_icon!(slots_reel_icon.id) == slots_reel_icon
    end

    test "create_slots_reel_icon/1 with valid data creates a slots_reel_icon" do
      valid_attrs = %{image: "some image", reel_0_index: 42, reel_1_index: 42, reel_2_index: 42}

      assert {:ok, %SlotsReelIcon{} = slots_reel_icon} =
               Minigames.create_slots_reel_icon(valid_attrs)

      assert slots_reel_icon.image == "some image"
      assert slots_reel_icon.reel_0_index == 42
      assert slots_reel_icon.reel_1_index == 42
      assert slots_reel_icon.reel_2_index == 42
    end

    test "create_slots_reel_icon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_slots_reel_icon(@invalid_attrs)
    end

    test "update_slots_reel_icon/2 with valid data updates the slots_reel_icon" do
      slots_reel_icon = slots_reel_icon_fixture()

      update_attrs = %{
        image: "some updated image",
        reel_0_index: 43,
        reel_1_index: 43,
        reel_2_index: 43
      }

      assert {:ok, %SlotsReelIcon{} = slots_reel_icon} =
               Minigames.update_slots_reel_icon(slots_reel_icon, update_attrs)

      assert slots_reel_icon.image == "some updated image"
      assert slots_reel_icon.reel_0_index == 43
      assert slots_reel_icon.reel_1_index == 43
      assert slots_reel_icon.reel_2_index == 43
    end

    test "update_slots_reel_icon/2 with invalid data returns error changeset" do
      slots_reel_icon = slots_reel_icon_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_slots_reel_icon(slots_reel_icon, @invalid_attrs)

      assert slots_reel_icon == Minigames.get_slots_reel_icon!(slots_reel_icon.id)
    end

    test "delete_slots_reel_icon/1 deletes the slots_reel_icon" do
      slots_reel_icon = slots_reel_icon_fixture()
      assert {:ok, %SlotsReelIcon{}} = Minigames.delete_slots_reel_icon(slots_reel_icon)

      assert_raise Ecto.NoResultsError, fn ->
        Minigames.get_slots_reel_icon!(slots_reel_icon.id)
      end
    end

    test "change_slots_reel_icon/1 returns a slots_reel_icon changeset" do
      slots_reel_icon = slots_reel_icon_fixture()
      assert %Ecto.Changeset{} = Minigames.change_slots_reel_icon(slots_reel_icon)
    end
  end

  describe "slots_paytables" do
    alias Safira.Minigames.SlotsPaytable

    import Safira.MinigamesFixtures

    @invalid_attrs %{
      multiplier: nil,
      position_figure_0: nil,
      position_figure_1: nil,
      position_figure_2: nil
    }

    test "list_slots_paytables/0 returns all slots_paytables" do
      slots_paytable = slots_paytable_fixture()
      assert Minigames.list_slots_paytables() == [slots_paytable]
    end

    test "get_slots_paytable!/1 returns the slots_paytable with given id" do
      slots_paytable = slots_paytable_fixture()
      assert Minigames.get_slots_paytable!(slots_paytable.id) == slots_paytable
    end

    test "create_slots_paytable/1 with valid data creates a slots_paytable" do
      valid_attrs = %{
        multiplier: 42,
        position_figure_0: 42,
        position_figure_1: 42,
        position_figure_2: 42
      }

      assert {:ok, %SlotsPaytable{} = slots_paytable} =
               Minigames.create_slots_paytable(valid_attrs)

      assert slots_paytable.multiplier == 42
      assert slots_paytable.position_figure_0 == 42
      assert slots_paytable.position_figure_1 == 42
      assert slots_paytable.position_figure_2 == 42
    end

    test "create_slots_paytable/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_slots_paytable(@invalid_attrs)
    end

    test "update_slots_paytable/2 with valid data updates the slots_paytable" do
      slots_paytable = slots_paytable_fixture()

      update_attrs = %{
        multiplier: 43,
        position_figure_0: 43,
        position_figure_1: 43,
        position_figure_2: 43
      }

      assert {:ok, %SlotsPaytable{} = slots_paytable} =
               Minigames.update_slots_paytable(slots_paytable, update_attrs)

      assert slots_paytable.multiplier == 43
      assert slots_paytable.position_figure_0 == 43
      assert slots_paytable.position_figure_1 == 43
      assert slots_paytable.position_figure_2 == 43
    end

    test "update_slots_paytable/2 with invalid data returns error changeset" do
      slots_paytable = slots_paytable_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_slots_paytable(slots_paytable, @invalid_attrs)

      assert slots_paytable == Minigames.get_slots_paytable!(slots_paytable.id)
    end

    test "delete_slots_paytable/1 deletes the slots_paytable" do
      slots_paytable = slots_paytable_fixture()
      assert {:ok, %SlotsPaytable{}} = Minigames.delete_slots_paytable(slots_paytable)

      assert_raise Ecto.NoResultsError, fn ->
        Minigames.get_slots_paytable!(slots_paytable.id)
      end
    end

    test "change_slots_paytable/1 returns a slots_paytable changeset" do
      slots_paytable = slots_paytable_fixture()
      assert %Ecto.Changeset{} = Minigames.change_slots_paytable(slots_paytable)
    end
  end
end
