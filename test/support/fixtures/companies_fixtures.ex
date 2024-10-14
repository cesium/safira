defmodule Safira.CompaniesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Companies` context.
  """

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> Enum.into(%{
        name: "some name",
        tier_id: tier_fixture().id
      })
      |> Safira.Companies.create_company()

    company
  end

  @doc """
  Generate a tier.
  """
  def tier_fixture(attrs \\ %{}) do
    {:ok, tier} =
      attrs
      |> Enum.into(%{
        name: "some name",
        priority: 42
      })
      |> Safira.Companies.create_tier()

    tier
  end
end
