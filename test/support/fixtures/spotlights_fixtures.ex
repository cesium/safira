defmodule Safira.SpotlightsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Spotlights` context.
  """

  @doc """
  Generate a spotlight.
  """
  def spotlight_fixture(attrs \\ %{}) do
    {:ok, spotlight} =
      attrs
      |> Enum.into(%{
        end: ~U[2024-11-20 22:32:00Z]
      })
      |> Safira.Spotlights.create_spotlight()

    spotlight
  end
end
