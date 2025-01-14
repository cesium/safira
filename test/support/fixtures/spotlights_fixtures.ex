defmodule Safira.SpotlightsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Spotlights` context.
  """

  alias Safira.CompaniesFixtures

  @doc """
  Generate a spotlight.
  """
  def spotlight_fixture do
    {:ok, spotlight} = Safira.Spotlights.create_spotlight(CompaniesFixtures.company_fixture().id)
    spotlight
  end
end
