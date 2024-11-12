defmodule Safira.CompaniesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Companies` context.
  """

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    {:ok, %{user: _, company: company}} =
      attrs
      |> Enum.into(%{
        name: "some name",
        handle: "handle",
        email: "handle@seium.org",
        password: "password1234",
        tier_id: tier_fixture().id
      })
      |> Safira.Companies.create_company_and_user()

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
