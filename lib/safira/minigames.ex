defmodule Safira.Minigames do
  @moduledoc """
  The Minigames context.
  """

  use Safira.Context

  alias Ecto.Multi

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Constants
  alias Safira.Contest
  alias Safira.Inventory.Item
  alias Safira.Minigames.{CoinFlipRoom, Prize, WheelDrop}
  alias Safira.Minigames.{Prize, WheelDrop}
  alias Safira.Minigames.{Prize, WheelDrop}

  @pubsub Safira.PubSub

  @doc """
  Returns the list of prizes.

  ## Examples

      iex> list_prizes()
      [%Prize{}, ...]

  """
  def list_prizes do
    Repo.all(Prize)
  end

  def list_prizes(opts) when is_list(opts) do
    Prize
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_prizes(params) do
    Prize
    |> Flop.validate_and_run(params, for: Prize)
  end

  def list_prizes(%{} = params, opts) when is_list(opts) do
    Prize
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Prize)
  end

  @doc """
  Gets a single prize.

  Raises `Ecto.NoResultsError` if the Prize does not exist.

  ## Examples

      iex> get_prize!(123)
      %Prize{}

      iex> get_prize!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prize!(id), do: Repo.get!(Prize, id)

  @doc """
  Creates a prize.

  ## Examples

      iex> create_prize(%{field: value})
      {:ok, %Prize{}}

      iex> create_prize(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prize(attrs \\ %{}) do
    %Prize{}
    |> Prize.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prize.

  ## Examples

      iex> update_prize(prize, %{field: new_value})
      {:ok, %Prize{}}

      iex> update_prize(prize, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prize(%Prize{} = prize, attrs) do
    prize
    |> Prize.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a prize image.

  ## Examples

      iex> update_prize_image(prize, %{image: image})
      {:ok, %Prize{}}

      iex> update_prize_image(prize, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_prize_image(%Prize{} = prize, attrs) do
    prize
    |> Prize.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prize.

  ## Examples

      iex> delete_prize(prize)
      {:ok, %Prize{}}

      iex> delete_prize(prize)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prize(%Prize{} = prize) do
    Repo.delete(prize)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prize changes.

  ## Examples

      iex> change_prize(prize)
      %Ecto.Changeset{data: %Prize{}}

  """
  def change_prize(%Prize{} = prize, attrs \\ %{}) do
    Prize.changeset(prize, attrs)
  end

  @doc """
  Returns the list of wheel_drops.

  ## Examples

      iex> list_wheel_drops()
      [%WheelDrop{}, ...]

  """
  def list_wheel_drops do
    Repo.all(WheelDrop)
  end

  @doc """
  Gets a single wheel_drop.

  Raises `Ecto.NoResultsError` if the Wheel drop does not exist.

  ## Examples

      iex> get_wheel_drop!(123)
      %WheelDrop{}

      iex> get_wheel_drop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wheel_drop!(id), do: Repo.get!(WheelDrop, id)

  @doc """
  Creates a wheel_drop.

  ## Examples

      iex> create_wheel_drop(%{field: value})
      {:ok, %WheelDrop{}}

      iex> create_wheel_drop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wheel_drop(attrs \\ %{}) do
    %WheelDrop{}
    |> WheelDrop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wheel_drop.

  ## Examples

      iex> update_wheel_drop(wheel_drop, %{field: new_value})
      {:ok, %WheelDrop{}}

      iex> update_wheel_drop(wheel_drop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wheel_drop(%WheelDrop{} = wheel_drop, attrs) do
    wheel_drop
    |> WheelDrop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wheel_drop.

  ## Examples

      iex> delete_wheel_drop(wheel_drop)
      {:ok, %WheelDrop{}}

      iex> delete_wheel_drop(wheel_drop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wheel_drop(%WheelDrop{} = wheel_drop) do
    Repo.delete(wheel_drop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wheel_drop changes.

  ## Examples

      iex> change_wheel_drop(wheel_drop)
      %Ecto.Changeset{data: %WheelDrop{}}

  """
  def change_wheel_drop(%WheelDrop{} = wheel_drop, attrs \\ %{}) do
    WheelDrop.changeset(wheel_drop, attrs)
  end

  @doc """
  Returns the type of the wheel drop.

  ## Examples

      iex> get_wheel_drop_type(%WheelDrop{} = wheel_drop)
      :prize

  """
  def get_wheel_drop_type(%WheelDrop{} = wheel_drop) do
    cond do
      wheel_drop.prize_id -> :prize
      wheel_drop.badge_id -> :badge
      wheel_drop.tokens && wheel_drop.tokens != 0 -> :tokens
      wheel_drop.entries && wheel_drop.entries != 0 -> :entries
      true -> nil
    end
  end

  @doc """
  Changes the wheel spin price.

  ## Examples

      iex> set_wheel_price(20)
      :ok
  """
  def change_wheel_price(price) do
    Constants.set("wheel_spin_price", price)
    broadcast_wheel_config_update("price", price)
  end

  @doc """
  Spins the wheel for the given attendee.

  ## Examples

      iex> spin_wheel(attendee)
      {:ok, :prize, %WheelDrop{}}

      iex> spin_wheel(attendee)
      {:ok, :tokens, %WheelDrop{}}

      iex> spin_wheel(attendee)
      {:ok, nil, %WheelDrop{}}
  """
  def spin_wheel(attendee) do
    attendee = Accounts.get_attendee!(attendee.id)

    if wheel_active?() do
      case spin_wheel_transaction(attendee) do
        {:ok, result} ->
          {:ok, get_wheel_drop_type(result.drop), result.drop}

        {:error, _} ->
          {:error, "An error occurred while spinning the wheel."}
      end
    else
      {:error, "The wheel is not active."}
    end
  end

  defp spin_wheel_transaction(attendee) do
    Multi.new()
    # Fetch the wheel spin price
    |> Multi.put(:wheel_price, get_wheel_price())
    # Remove the wheel spin price from the attendee's token balance
    |> Multi.merge(fn %{wheel_price: price} ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - price, :attendee)
    end)
    # Fetch a random drop according to the probabilities and available stock of drops with prizes
    |> Multi.run(:drop, fn _repo, %{attendee: attendee} ->
      {:ok, generate_valid_wheel_drop(attendee)}
    end)
    # Apply the reward action for the drop
    |> Multi.merge(fn %{drop: drop, attendee: attendee} ->
      drop_reward_action(drop, attendee)
    end)
    # Execute the transaction
    |> Repo.transaction()
  end

  defp generate_valid_wheel_drop(attendee) do
    drop = generate_wheel_drop()

    case get_wheel_drop_type(drop) do
      :prize ->
        if get_attendee_prize_inventory_quantity(attendee.id, drop.prize_id) <
             drop.max_per_attendee do
          drop
        else
          # If the attendee already has maximum amount of prize, they win nothing
          %WheelDrop{}
        end

      _ ->
        drop
    end
  end

  @doc """
  Simulates a wheel spin.
  """
  def simulate_wheel_spin do
    drop = generate_wheel_drop()

    {:ok, get_wheel_drop_type(drop), drop}
  end

  defp generate_wheel_drop do
    random = strong_randomizer() |> Float.round(12)

    drops = list_available_wheel_drops()

    cumulative_probabilities =
      drops
      |> Enum.sort_by(& &1.probability)
      |> Enum.map_reduce(0, fn drop, acc ->
        {Float.round(acc + drop.probability, 12), acc + drop.probability}
      end)

    cumulatives =
      cumulative_probabilities
      |> elem(0)
      |> Enum.concat([1])

    sum =
      cumulative_probabilities
      |> elem(1)

    remaining_probability = 1 - sum

    real_drops =
      Enum.sort_by(drops, & &1.probability) ++ [%WheelDrop{probability: remaining_probability}]

    prob =
      cumulatives
      |> Enum.filter(fn x -> x >= random end)
      |> Enum.at(0)

    real_drops
    |> Enum.at(cumulatives |> Enum.find_index(fn x -> x == prob end))
  end

  defp drop_reward_action(drop, attendee) do
    case get_wheel_drop_type(drop) do
      :prize ->
        Multi.new()
        |> Multi.insert(
          :item,
          Item.changeset(%Item{}, %{
            prize_id: drop.prize_id,
            attendee_id: attendee.id,
            type: :prize
          })
        )
        |> Multi.update(
          :prize,
          Prize.update_stock_changeset(drop.prize, %{stock: drop.prize.stock - 1})
        )

      :badge ->
        # TODO: REDEEM BADGE
        Multi.new()

      :tokens ->
        Contest.change_attendee_tokens_transaction(
          attendee,
          attendee.tokens + drop.tokens,
          :attendee_state_tokens,
          :previous_daily_tokens,
          :new_daily_tokens
        )

      :entries ->
        Multi.new()
        |> Multi.update(
          :attendee_state_entries,
          Attendee.update_entries_changeset(attendee, %{entries: attendee.entries + drop.entries})
        )

      nil ->
        Multi.new()
    end
  end

  defp get_attendee_prize_inventory_quantity(attendee_id, prize_id) do
    Item
    |> where([i], i.attendee_id == ^attendee_id and i.prize_id == ^prize_id)
    |> Repo.aggregate(:count)
  end

  def list_available_wheel_drops do
    WheelDrop
    |> join(:left, [wd], p in Prize, on: wd.prize_id == p.id)
    |> where([wd, p], is_nil(wd.prize_id) or p.stock > 0)
    |> preload([:prize, :badge])
    |> Repo.all()
  end

  @doc """
  Gets the wheel spin price.

  ## Examples

      iex> get_wheel_price()
      20
  """
  def get_wheel_price do
    case Constants.get("wheel_spin_price") do
      {:ok, price} ->
        price

      {:error, _} ->
        # If the price is not set, set it to 0 by default
        change_wheel_price(0)
        0
    end
  end

  @doc """
  Changes the wheel active status.

  ## Examples

      iex> change_wheel_active(true)
      :ok
  """
  def change_wheel_active(active) do
    Constants.set("wheel_active_status", active)
    broadcast_wheel_config_update("is_active", active)
  end

  @doc """
  Gets the wheel active status.

  ## Examples

      iex> wheel_active?()
      true
  """
  def wheel_active? do
    case Constants.get("wheel_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to false by default
        change_wheel_active(true)
        true
    end
  end

  @doc """
  Subscribes the caller to the wheel's configuration updates.

  ## Examples

      iex> subscribe_to_wheel_config_update()
      :ok
  """
  def subscribe_to_wheel_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, wheel_config_topic(config))
  end

  defp wheel_config_topic(config), do: "wheel:#{config}"

  defp broadcast_wheel_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, wheel_config_topic(config), {config, value})
  end

  # Generates a random number using the Erlang crypto module
  defp strong_randomizer do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsplus, {i1, i2, i3})
    :rand.uniform()
  end

  @doc """
  Returns the list of coin_flip_rooms.

  ## Examples

      iex> list_coin_flip_rooms()
      [%CoinFlipRoom{}, ...]

  """
  def list_coin_flip_rooms do
    CoinFlipRoom
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
  Returns the list of current active coin flip rooms, ordered by most recent first.

  ## Examples

      iex> list_current_coin_flip_rooms()
      [%CoinFlipRoom{finished: false}, ...]
  """
  def list_current_coin_flip_rooms do
    CoinFlipRoom
    |> where([r], not r.finished)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
    Returns the list of previous (finished) coin flip rooms, ordered by most recent first.

    ## Examples

        iex> list_previous_coin_flip_rooms()
        [%CoinFlipRoom{finished: true}, ...]
        iex> list_previous_coin_flip_rooms(10)
        [%CoinFlipRoom{finished: true}, ...]
  """
  def list_previous_coin_flip_rooms(limit \\ nil) do
    query =
      CoinFlipRoom
      |> where([r], r.finished)
      |> order_by([r], desc: r.inserted_at)

    query = if limit, do: query |> limit(^limit), else: query

    query
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
  Gets a single coin_flip_room.

  Raises `Ecto.NoResultsError` if the Coin flip room does not exist.

  ## Examples

      iex> get_coin_flip_room!(123)
      %CoinFlipRoom{}

      iex> get_coin_flip_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coin_flip_room!(id) do
    CoinFlipRoom
    |> Repo.get!(id)
    |> Repo.preload(player1: :user, player2: :user)
  end

  defp create_coin_flip_room_transaction(attendee, bet) do
    Multi.new()
    # Fetch the room play cost
    |> Multi.put(:bet, bet)
    # Remove the room play cost from the attendee's token balance
    |> Multi.merge(fn %{bet: bet} ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - bet, :attendee)
    end)
    # Create the coin flip room
    |> Multi.run(:coin_flip_room, fn _repo, %{attendee: attendee} ->
      attrs = %{
        player1_id: attendee.id,
        bet: bet
      }

      %CoinFlipRoom{}
      |> CoinFlipRoom.changeset(attrs)
      |> Repo.insert()
    end)
    # Execute the transaction
    |> Repo.transaction()
  end

  @doc """
  Creates a coin_flip_room.

  ## Examples

      iex> create_coin_flip_room(%{field: value})
      {:ok, %CoinFlipRoom{}}

      iex> create_coin_flip_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coin_flip_room(attrs \\ %{}) do
    attendee = Accounts.get_attendee!(attrs["attendee_id"])

    cond do
      not coin_flip_active?() ->
        {:error, "The coin flip game is not active."}

      has_active_coin_flip_game?(attendee.id) ->
        {:error, "You already have an active game."}

      attrs["bet"] <= 0 ->
        {:error, "The bet amount must be greater than 0."}

      true ->
        case create_coin_flip_room_transaction(attendee, attrs["bet"]) do
          {:ok, result} ->
            coin_flip_room = Repo.preload(result.coin_flip_room, player1: :user)
            broadcast_coin_flip_rooms_update("create", coin_flip_room)
            {:ok, coin_flip_room}

          {:error, _, changeset, _} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Updates a coin_flip_room.

  ## Examples

      iex> update_coin_flip_room(coin_flip_room, %{field: new_value})
      %CoinFlipRoom{}

  """
  def update_coin_flip_room(%CoinFlipRoom{} = coin_flip_room, attrs) do
    changeset = CoinFlipRoom.changeset(coin_flip_room, attrs)

    case Repo.update(changeset) do
      {:ok, coin_flip_room} ->
        {:ok, coin_flip_room}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp delete_coin_flip_room_transaction(room) do
    Multi.new()
    |> Multi.merge(fn _changes ->
      Contest.change_attendee_tokens_transaction(
        room.player1,
        room.player1.tokens + room.bet,
        :player1
      )
    end)
    |> Multi.delete(:coin_flip_room, room)
    |> Repo.transaction()
  end

  @doc """
  Deletes a coin_flip_room.

  ## Examples

      iex> delete_coin_flip_room(coin_flip_room)
      {:ok, %CoinFlipRoom{}}

      iex> delete_coin_flip_room(coin_flip_room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coin_flip_room(%CoinFlipRoom{} = coin_flip_room) do
    if coin_flip_room.finished do
      {:error, "The room is already finished."}
    else
      case delete_coin_flip_room_transaction(coin_flip_room) do
        {:ok, _} ->
          broadcast_coin_flip_rooms_update("delete", coin_flip_room)
          {:ok, coin_flip_room}

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  @doc """
  Checks if an attendee has an active (unfinished) coin flip game.

  Takes an attendee id and checks if they are either player1 or player2 in any unfinished coin flip room.

  ## Parameters
    * `attendee_id` - The id of the attendee to check

  ## Returns
    * `true` - If the attendee has an active game
    * `false` - If the attendee has no active games

  ## Examples

      iex> has_active_coin_flip_game?(123)
      true

      iex> has_active_coin_flip_game?(456)
      false
  """
  def has_active_coin_flip_game?(attendee_id) do
    CoinFlipRoom
    |> where([r], not r.finished)
    |> where([r], r.player1_id == ^attendee_id or r.player2_id == ^attendee_id)
    |> Repo.exists?()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coin_flip_room changes.

  ## Examples

      iex> change_coin_flip_room(coin_flip_room)
      %Ecto.Changeset{data: %CoinFlipRoom{}}

  """
  def change_coin_flip_room(%CoinFlipRoom{} = coin_flip_room, attrs \\ %{}) do
    CoinFlipRoom.changeset(coin_flip_room, attrs)
  end

  @doc """
  Changes the coin flip fee.

  ## Examples

      iex> set_coin_flip_fee(20)
      :ok
  """
  def change_coin_flip_fee(fee) do
    Constants.set("coin_flip_fee", fee)
    broadcast_coin_flip_config_update("fee", fee)
  end

  @doc """
  Gets the coin flip fee.

  ## Examples

      iex> get_coin_flip_fee()
      20
  """
  def get_coin_flip_fee do
    case Constants.get("coin_flip_fee") do
      {:ok, fee} ->
        fee

      {:error, _} ->
        # If the fee is not set, set it to 0 by default
        change_coin_flip_fee(0)
        0
    end
  end

  @doc """
  Changes the coin flip active status.

  ## Examples

      iex> change_coin_flip_active(true)
      :ok
  """
  def change_coin_flip_active(active) do
    Constants.set("coin_flip_active_status", active)
    broadcast_coin_flip_config_update("is_active", active)
  end

  @doc """
  Gets the coin flip active status.

  ## Examples

      iex> coin_flip_active?()
      true
  """
  def coin_flip_active? do
    case Constants.get("coin_flip_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to false by default
        change_coin_flip_active(true)
        true
    end
  end

  defp join_coin_flip_room_transaction(room, attendee_id) do
    attendee = Accounts.get_attendee!(attendee_id)

    Multi.new()
    # Remove the room play cost from player2's balance
    |> Multi.merge(fn _changes ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - room.bet, :player2)
    end)
    # Flip the coin and update the room
    |> Multi.run(:coin_flip_room, fn repo, _changes ->
      result = flip_coin()

      room
      |> CoinFlipRoom.changeset(%{
        player2_id: attendee_id,
        result: result,
        finished: true
      })
      |> repo.update()
    end)
    # Award tokens to winner
    |> Multi.merge(fn %{coin_flip_room: updated_room, player2: player2} ->
      updated_room = Repo.preload(updated_room, [:player1, :player2])
      winner = if updated_room.result == "tails", do: player2, else: updated_room.player1

      fee =
        case Constants.get("coin_flip_fee") do
          {:ok, fee} -> fee
          {:error, _} -> 0
        end

      winnings = floor(room.bet * 2 * (1 - fee))

      Contest.change_attendee_tokens_transaction(
        winner,
        winner.tokens + winnings,
        :winner_update_tokens,
        :previous_daily_tokens,
        :new_daily_tokens
      )
    end)
    |> Repo.transaction()
  end

  @doc """
  Joins an attendee to a coin flip room.

  ## Parameters

    - room_id: The ID of the coin flip room to join.
    - attendee: The attendee attempting to join the room.

  ## Returns

    - `{:ok, "You have joined the room."}` if the attendee successfully joins the room.
    - `{:error, "You cannot join your own room."}` if the attendee is trying to join their own room.
    - `{:error, "The room is already full."}` if the room already has two players.

  ## Examples

      iex> join_coin_flip_room("room_id", %Attendee{id: "attendee_id"})
      {:ok, "You have joined the room."}

      iex> join_coin_flip_room("room_id", %Attendee{id: "player1_id"})
      {:error, "You cannot join your own room."}

      iex> join_coin_flip_room("room_id", %Attendee{id: "other_attendee_id"})
      {:error, "The room is already full."}
  """
  def join_coin_flip_room(room_id, attendee) do
    cond do
      not coin_flip_active?() ->
        {:error, "The coin flip game is not active."}

      has_active_coin_flip_game?(attendee.id) ->
        {:error, "You already have an active game."}

      true ->
        case get_coin_flip_room!(room_id) do
          %CoinFlipRoom{player1_id: player1_id} when player1_id == attendee.id ->
            {:error, "You cannot join your own room."}

          %CoinFlipRoom{player2_id: nil} = room ->
            case join_coin_flip_room_transaction(room, attendee.id) do
              {:ok, result} ->
                coin_flip_room =
                  result.coin_flip_room
                  |> Map.put(:finished, false)
                  |> Map.put(:player2, attendee)
                  |> Repo.preload(player2: :user)

                broadcast_coin_flip_rooms_update("update", coin_flip_room)
                {:ok, coin_flip_room}

              {:error, _, _changeset, _} ->
                {:error, "Failed to join the room."}
            end

          _ ->
            {:error, "The room is already full."}
        end
    end
  end

  defp flip_coin do
    if strong_randomizer() > 0.5 do
      "heads"
    else
      "tails"
    end
  end

  @doc """
  Subscribes the caller to the coin flip's configuration updates.

  ## Examples

      iex> subscribe_to_coin_flip_config_update()
      :ok
  """
  def subscribe_to_coin_flip_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, coin_flip_config_topic(config))
  end

  defp coin_flip_config_topic(config), do: "coin_flip_config:#{config}"

  defp broadcast_coin_flip_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, coin_flip_config_topic(config), {config, value})
  end

  @doc """
  Subscribes the caller to the coin flip rooms updates.

  ## Examples

      iex> subscribe_to_coin_flip_rooms_update()
      :ok
  """
  def subscribe_to_coin_flip_rooms_update do
    Phoenix.PubSub.subscribe(@pubsub, coin_flip_rooms_topic())
  end

  defp coin_flip_rooms_topic, do: "coin_flip_rooms"

  defp broadcast_coin_flip_rooms_update(action, value) do
    Phoenix.PubSub.broadcast(@pubsub, coin_flip_rooms_topic(), {action, value})
  end
end
