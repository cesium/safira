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
end
