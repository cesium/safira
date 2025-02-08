defmodule Safira.CompaniesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Companies` context.
  """

  alias Safira.Companies.Company

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "user" => %{
          "name" => "some name",
          "handle" => "handle",
          "email" => "handle@seium.org",
          "password" => "password1234"
        },
        "name" => "some name",
        "tier_id" => tier_fixture().id
      })

    {:ok, %{user: _, company: company}} =
      Safira.Companies.upsert_company_and_user(%Company{}, attrs)

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
