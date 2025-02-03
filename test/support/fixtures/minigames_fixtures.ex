defmodule Safira.MinigamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Minigames` context.
  """

  @doc """
  Generate a prize.
  """
  def prize_fixture(attrs \\ %{}) do
    {:ok, prize} =
      attrs
      |> Enum.into(%{
        name: "some name",
        stock: 42
      })
      |> Safira.Minigames.create_prize()

    prize
  end

  @doc """
  Generate a wheel_drop.
  """
  def wheel_drop_fixture(attrs \\ %{}) do
    {:ok, wheel_drop} =
      attrs
      |> Enum.into(%{
        max_per_attendee: 42,
        probability: 0.2
      })
      |> Safira.Minigames.create_wheel_drop()

    wheel_drop
  end

  @doc """
  Generate a coin_flip_room.
  """
  def coin_flip_room_fixture(attrs \\ %{}) do
    {:ok, coin_flip_room} =
      attrs
      |> Enum.into(%{
        bet: 42
      })
      |> Safira.Minigames.create_coin_flip_room()

    coin_flip_room
  end

  defp valid_icon_upload do
    %Plug.Upload{
      filename: "reel1.svg",
      path: Path.expand("priv/fake/images/reel1.svg", File.cwd!())
    }
  end

  @doc """
  Generate a slots_reel_icon.
  """
  def slots_reel_icon_fixture(attrs \\ %{}) do
    {:ok, slots_reel_icon} =
      attrs
      |> Enum.into(%{
        image: valid_icon_upload(),
        reel_0_index: 42,
        reel_1_index: 42,
        reel_2_index: 42
      })
      |> Safira.Minigames.create_slots_reel_icon()

    slots_reel_icon
  end

  @doc """
  Generate a slots_paytable.
  """
  def slots_paytable_fixture(attrs \\ %{}) do
    {:ok, slots_paytable} =
      attrs
      |> Enum.into(%{
        position_figure_0: 42,
        position_figure_1: 42,
        position_figure_2: 42,
        multiplier: 42,
        # Add the required probability field.
        probability: 0.1
      })
      |> Safira.Minigames.create_slots_paytable()

    slots_paytable
  end

  @doc """
  Generate a slots_payline.
  """
  def slots_payline_fixture(attrs \\ %{}) do
    # Ensure there is a valid paytable_id using the paytable fixture.
    paytable = Map.get(attrs, :paytable) || slots_paytable_fixture()

    {:ok, slots_payline} =
      attrs
      |> Enum.into(%{
        position_0: 42,
        position_1: 42,
        position_2: 42,
        paytable_id: paytable.id
      })
      |> Safira.Minigames.create_slots_payline()

    slots_payline
  end
end
