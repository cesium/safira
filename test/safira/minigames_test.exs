defmodule Safira.MinigamesTest do
  use Safira.DataCase

  alias Safira.Minigames

  describe "prizes" do
    alias Safira.Minigames.Prize

    import Safira.MinigamesFixtures

    @invalid_attrs %{name: nil, stock: nil}

    test "list_prizes/0 returns all prizes" do
      prize = prize_fixture()
      assert prize.id in Enum.map(Minigames.list_prizes(), & &1.id)
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
      assert Enum.map(Minigames.list_wheel_drops(), fn d -> d.id end) == [wheel_drop.id]
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
      assert slots_reel_icon.id in Enum.map(Minigames.list_slots_reel_icons(), & &1.id)
    end

    test "get_slots_reel_icon!/1 returns the slots_reel_icon with given id" do
      slots_reel_icon = slots_reel_icon_fixture()
      assert Minigames.get_slots_reel_icon!(slots_reel_icon.id) == slots_reel_icon
    end

    test "create_slots_reel_icon/1 with valid data creates a slots_reel_icon" do
      valid_attrs = %{
        image: %Plug.Upload{
          filename: "reel1.svg",
          path: Path.expand("priv/fake/images/reel1.svg", File.cwd!())
        },
        reel_0_index: 42,
        reel_1_index: 42,
        reel_2_index: 42
      }

      assert {:ok, %SlotsReelIcon{} = slots_reel_icon} =
               Minigames.create_slots_reel_icon(valid_attrs)

      # Depending on your uploader, assert on a property (or string conversion) of image.
      assert is_map(slots_reel_icon.image)
      assert slots_reel_icon.image.file_name == "reel1.svg"
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
        image: %Plug.Upload{
          filename: "reel2.svg",
          path: Path.expand("priv/fake/images/reel2.svg", File.cwd!())
        },
        reel_0_index: 43,
        reel_1_index: 43,
        reel_2_index: 43
      }

      assert {:ok, %SlotsReelIcon{} = slots_reel_icon} =
               Minigames.update_slots_reel_icon(slots_reel_icon, update_attrs)

      assert is_map(slots_reel_icon.image)
      assert slots_reel_icon.image.file_name == "reel2.svg"
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
      multiplier: -3,
      position_figure_0: -1,
      position_figure_1: -2,
      position_figure_2: -3
    }

    test "list_slots_paytables/0 returns all slots_paytables" do
      slots_paytable = slots_paytable_fixture()
      assert slots_paytable.id in Enum.map(Minigames.list_slots_paytables(), & &1.id)
    end

    test "get_slots_paytable!/1 returns the slots_paytable with given id" do
      slots_paytable = slots_paytable_fixture()
      assert Minigames.get_slots_paytable!(slots_paytable.id) == slots_paytable
    end

    test "create_slots_paytable/1 with valid data creates a slots_paytable" do
      valid_attrs = %{
        multiplier: 42,
        probability: 0.1,
        position_figure_0: 42,
        position_figure_1: 42,
        position_figure_2: 42
      }

      assert {:ok, %SlotsPaytable{} = slots_paytable} =
               Minigames.create_slots_paytable(valid_attrs)

      assert slots_paytable.multiplier == 42
      # If you no longer store the position_figure_* fields, then assert on probability instead:
      assert slots_paytable.probability == 0.1
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

  describe "slots_paylines" do
    alias Safira.Minigames.SlotsPayline

    import Safira.MinigamesFixtures

    @invalid_attrs %{position_1: -1, position_0: -2, position_2: -3, probability: nil}

    test "list_slots_paylines/0 returns all slots_paylines" do
      slots_payline = slots_payline_fixture()
      assert slots_payline.id in Enum.map(Minigames.list_slots_paylines(), & &1.id)
    end

    test "get_slots_payline!/1 returns the slots_payline with given id" do
      slots_payline = slots_payline_fixture()
      assert Minigames.get_slots_payline!(slots_payline.id) == slots_payline
    end

    test "create_slots_payline/1 with valid data creates a slots_payline" do
      paytable = slots_paytable_fixture()
      valid_attrs = %{position_1: 42, position_0: 42, position_2: 42, paytable_id: paytable.id}

      assert {:ok, %SlotsPayline{} = slots_payline} = Minigames.create_slots_payline(valid_attrs)
      assert slots_payline.position_1 == 42
      assert slots_payline.position_0 == 42
      assert slots_payline.position_2 == 42
    end

    test "create_slots_payline/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_slots_payline(@invalid_attrs)
    end

    test "update_slots_payline/2 with valid data updates the slots_payline" do
      slots_payline = slots_payline_fixture()
      update_attrs = %{position_1: 43, position_0: 43, position_2: 43}

      assert {:ok, %SlotsPayline{} = slots_payline} =
               Minigames.update_slots_payline(slots_payline, update_attrs)

      assert slots_payline.position_1 == 43
      assert slots_payline.position_0 == 43
      assert slots_payline.position_2 == 43
    end

    test "update_slots_payline/2 with invalid data returns error changeset" do
      slots_payline = slots_payline_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_slots_payline(slots_payline, @invalid_attrs)

      assert slots_payline == Minigames.get_slots_payline!(slots_payline.id)
    end

    test "delete_slots_payline/1 deletes the slots_payline" do
      slots_payline = slots_payline_fixture()
      assert {:ok, %SlotsPayline{}} = Minigames.delete_slots_payline(slots_payline)
      assert_raise Ecto.NoResultsError, fn -> Minigames.get_slots_payline!(slots_payline.id) end
    end

    test "change_slots_payline/1 returns a slots_payline changeset" do
      slots_payline = slots_payline_fixture()
      assert %Ecto.Changeset{} = Minigames.change_slots_payline(slots_payline)
    end
  end

  describe "scratch_cards" do
    alias Safira.Minigames.ScratchCard

    import Safira.MinigamesFixtures
    import Safira.AccountsFixtures

    @invalid_attrs %{attendee_id: nil}

    test "list_scratch_cards/0 returns all scratch_cards" do
      scratch_card = scratch_card_fixture()
      assert scratch_card.id in Enum.map(Minigames.list_scratch_cards(), & &1.id)
    end

    test "get_scratch_card!/1 returns the scratch_card with given id" do
      scratch_card = scratch_card_fixture()
      assert Minigames.get_scratch_card!(scratch_card.id) == scratch_card
    end

    test "create_scratch_card/1 with valid data creates a scratch_card" do
      attendee = attendee_fixture()
      valid_attrs = %{attendee_id: attendee.id}

      assert {:ok, %ScratchCard{} = scratch_card} = Minigames.create_scratch_card(valid_attrs)
      assert scratch_card.attendee_id == attendee.id
    end

    test "create_scratch_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_scratch_card(@invalid_attrs)
    end

    test "update_scratch_card/2 with valid data updates the scratch_card" do
      scratch_card = scratch_card_fixture()
      new_attendee = Safira.AccountsFixtures.attendee_fixture()
      update_attrs = %{attendee_id: new_attendee.id}

      assert {:ok, %ScratchCard{} = scratch_card} =
               Minigames.update_scratch_card(scratch_card, update_attrs)

      assert scratch_card.attendee_id == new_attendee.id
    end

    test "update_scratch_card/2 with invalid data returns error changeset" do
      scratch_card = scratch_card_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_scratch_card(scratch_card, @invalid_attrs)

      assert scratch_card == Minigames.get_scratch_card!(scratch_card.id)
    end

    test "delete_scratch_card/1 deletes the scratch_card" do
      scratch_card = scratch_card_fixture()
      assert {:ok, %ScratchCard{}} = Minigames.delete_scratch_card(scratch_card)
      assert_raise Ecto.NoResultsError, fn -> Minigames.get_scratch_card!(scratch_card.id) end
    end

    test "change_scratch_card/1 returns a scratch_card changeset" do
      scratch_card = scratch_card_fixture()
      assert %Ecto.Changeset{} = Minigames.change_scratch_card(scratch_card)
    end
  end

  describe "scratch_card_drops" do
    alias Safira.Minigames.ScratchCardDrop

    import Safira.MinigamesFixtures

    @invalid_attrs %{
      tokens: nil,
      probability: nil,
      entries: nil,
      max_per_attendee: nil
    }

    test "list_scratch_card_drops/0 returns all scratch_card_drops" do
      scratch_card_drop = scratch_card_drop_fixture()
      assert scratch_card_drop.id in Enum.map(Minigames.list_scratch_card_drops(), & &1.id)
    end

    test "get_scratch_card_drop!/1 returns the scratch_card_drop with given id" do
      scratch_card_drop = scratch_card_drop_fixture()
      assert Minigames.get_scratch_card_drop!(scratch_card_drop.id) == scratch_card_drop
    end

    test "create_scratch_card_drop/1 with valid data creates a scratch_card_drop" do
      valid_attrs = %{
        tokens: 42,
        probability: 0.5,
        entries: 42,
        max_per_attendee: 42
      }

      assert {:ok, %ScratchCardDrop{} = scratch_card_drop} =
               Minigames.create_scratch_card_drop(valid_attrs)

      assert scratch_card_drop.tokens == 42
      assert scratch_card_drop.probability == 0.5
      assert scratch_card_drop.entries == 42
      assert scratch_card_drop.max_per_attendee == 42
    end

    test "create_scratch_card_drop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_scratch_card_drop(@invalid_attrs)
    end

    test "update_scratch_card_drop/2 with valid data updates the scratch_card_drop" do
      scratch_card_drop = scratch_card_drop_fixture()

      update_attrs = %{
        tokens: 43,
        probability: 0.7,
        entries: 43,
        max_per_attendee: 43
      }

      assert {:ok, %ScratchCardDrop{} = scratch_card_drop} =
               Minigames.update_scratch_card_drop(scratch_card_drop, update_attrs)

      assert scratch_card_drop.tokens == 43
      assert scratch_card_drop.probability == 0.7
      assert scratch_card_drop.entries == 43
      assert scratch_card_drop.max_per_attendee == 43
    end

    test "update_scratch_card_drop/2 with invalid data returns error changeset" do
      scratch_card_drop = scratch_card_drop_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_scratch_card_drop(scratch_card_drop, @invalid_attrs)

      assert scratch_card_drop == Minigames.get_scratch_card_drop!(scratch_card_drop.id)
    end

    test "delete_scratch_card_drop/1 deletes the scratch_card_drop" do
      scratch_card_drop = scratch_card_drop_fixture()
      assert {:ok, %ScratchCardDrop{}} = Minigames.delete_scratch_card_drop(scratch_card_drop)

      assert_raise Ecto.NoResultsError, fn ->
        Minigames.get_scratch_card_drop!(scratch_card_drop.id)
      end
    end

    test "change_scratch_card_drop/1 returns a scratch_card_drop changeset" do
      scratch_card_drop = scratch_card_drop_fixture()
      assert %Ecto.Changeset{} = Minigames.change_scratch_card_drop(scratch_card_drop)
    end
  end

  describe "scratch_card_symbols" do
    alias Safira.Minigames.ScratchCardSymbol

    import Safira.MinigamesFixtures

    @invalid_attrs %{name: nil, image: nil}

    test "list_scratch_card_symbols/0 returns all scratch_card_symbols" do
      scratch_card_symbol = scratch_card_symbol_fixture()
      assert scratch_card_symbol.id in Enum.map(Minigames.list_scratch_card_symbols(), & &1.id)
    end

    test "get_scratch_card_symbol!/1 returns the scratch_card_symbol with given id" do
      scratch_card_symbol = scratch_card_symbol_fixture()
      assert Minigames.get_scratch_card_symbol!(scratch_card_symbol.id) == scratch_card_symbol
    end

    test "create_scratch_card_symbol/1 with valid data creates a scratch_card_symbol" do
      valid_attrs = %{
        name: "some name",
        image: %Plug.Upload{
          filename: "symbol.svg",
          path: Path.expand("priv/fake/images/reel1.svg", File.cwd!())
        }
      }

      assert {:ok, %ScratchCardSymbol{} = scratch_card_symbol} =
               Minigames.create_scratch_card_symbol(valid_attrs)

      assert scratch_card_symbol.name == "some name"
      assert is_map(scratch_card_symbol.image)
    end

    test "create_scratch_card_symbol/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Minigames.create_scratch_card_symbol(@invalid_attrs)
    end

    test "update_scratch_card_symbol/2 with valid data updates the scratch_card_symbol" do
      scratch_card_symbol = scratch_card_symbol_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ScratchCardSymbol{} = scratch_card_symbol} =
               Minigames.update_scratch_card_symbol(scratch_card_symbol, update_attrs)

      assert scratch_card_symbol.name == "some updated name"
    end

    test "update_scratch_card_symbol/2 with invalid data returns error changeset" do
      scratch_card_symbol = scratch_card_symbol_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Minigames.update_scratch_card_symbol(scratch_card_symbol, @invalid_attrs)

      assert scratch_card_symbol == Minigames.get_scratch_card_symbol!(scratch_card_symbol.id)
    end

    test "delete_scratch_card_symbol/1 deletes the scratch_card_symbol" do
      scratch_card_symbol = scratch_card_symbol_fixture()

      assert {:ok, %ScratchCardSymbol{}} =
               Minigames.delete_scratch_card_symbol(scratch_card_symbol)

      assert_raise Ecto.NoResultsError, fn ->
        Minigames.get_scratch_card_symbol!(scratch_card_symbol.id)
      end
    end

    test "change_scratch_card_symbol/1 returns a scratch_card_symbol changeset" do
      scratch_card_symbol = scratch_card_symbol_fixture()
      assert %Ecto.Changeset{} = Minigames.change_scratch_card_symbol(scratch_card_symbol)
    end
  end

  describe "buy_scratch_card/1" do
    import Safira.MinigamesFixtures
    import Safira.AccountsFixtures

    alias Safira.Accounts

    setup do
      Minigames.change_scratch_card_active(true)
      Minigames.change_scratch_card_price(10)

      %{attendee: attendee_fixture(%{tokens: 100})}
    end

    test "a winning card shows the winning symbol exactly 3 times", %{attendee: attendee} do
      [winning | _] = for _ <- 1..6, do: scratch_card_symbol_fixture()

      scratch_card_drop_fixture(%{
        probability: 1.0,
        tokens: 5,
        entries: 0,
        scratch_card_symbol_id: winning.id
      })

      assert {:ok, %{scratch_card_preloaded: card}} = Minigames.buy_scratch_card(attendee)

      counts = card |> Minigames.get_symbols_from_scratch_card() |> symbol_counts()

      assert counts |> Map.values() |> Enum.sum() == 6
      assert counts[winning.id] == 3
      assert Accounts.get_attendee!(attendee.id).tokens == 100 - 10 + 5
    end

    test "a losing card never has three matching symbols", %{attendee: attendee} do
      for _ <- 1..6, do: scratch_card_symbol_fixture()

      assert {:ok, %{scratch_card_preloaded: card}} = Minigames.buy_scratch_card(attendee)

      counts = card |> Minigames.get_symbols_from_scratch_card() |> symbol_counts()

      assert counts |> Map.values() |> Enum.sum() == 6
      assert counts |> Map.values() |> Enum.all?(&(&1 <= 2))
      assert Accounts.get_attendee!(attendee.id).tokens == 100 - 10
    end

    defp symbol_counts(symbols), do: symbols |> Enum.map(& &1.id) |> Enum.frequencies()
  end
end
