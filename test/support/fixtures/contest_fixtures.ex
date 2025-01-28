defmodule Safira.ContestFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Contest` context.
  """

  @doc """
  Generate a badge_redeem.
  """
  def badge_redeem_fixture(attrs \\ %{}) do
    {:ok, badge_redeem} =
      attrs
      |> Enum.into(%{})
      |> Safira.Contest.create_badge_redeem()

    badge_redeem
  end
end
