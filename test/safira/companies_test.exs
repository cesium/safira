defmodule Safira.CompaniesTest do
  use Safira.DataCase

  alias Safira.Companies

  describe "companies" do
    alias Safira.Companies.Company

    import Safira.AccountsFixtures
    import Safira.CompaniesFixtures

    @invalid_attrs %{name: nil}

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Companies.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Companies.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{
        name: "some name",
        handle: "handle",
        email: "email@seium.org",
        password: "password1234",
        user_id: user_fixture().id,
        tier_id: tier_fixture().id
      }

      assert {:ok, %Company{} = company} = Companies.create_company(valid_attrs)
      assert company.name == "some name"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Companies.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Company{} = company} = Companies.update_company(company, update_attrs)
      assert company.name == "some updated name"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Companies.update_company(company, @invalid_attrs)
      assert company == Companies.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Companies.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Companies.change_company(company)
    end
  end

  describe "tiers" do
    alias Safira.Companies.Tier

    import Safira.CompaniesFixtures

    @invalid_attrs %{name: nil, priority: nil}

    test "list_tiers/0 returns all tiers" do
      tier = tier_fixture()
      assert Companies.list_tiers() == [tier]
    end

    test "get_tier!/1 returns the tier with given id" do
      tier = tier_fixture()
      assert Companies.get_tier!(tier.id) == tier
    end

    test "create_tier/1 with valid data creates a tier" do
      valid_attrs = %{name: "some name", priority: 42}

      assert {:ok, %Tier{} = tier} = Companies.create_tier(valid_attrs)
      assert tier.name == "some name"
      assert tier.priority == 42
    end

    test "create_tier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Companies.create_tier(@invalid_attrs)
    end

    test "update_tier/2 with valid data updates the tier" do
      tier = tier_fixture()
      update_attrs = %{name: "some updated name", priority: 43}

      assert {:ok, %Tier{} = tier} = Companies.update_tier(tier, update_attrs)
      assert tier.name == "some updated name"
      assert tier.priority == 43
    end

    test "update_tier/2 with invalid data returns error changeset" do
      tier = tier_fixture()
      assert {:error, %Ecto.Changeset{}} = Companies.update_tier(tier, @invalid_attrs)
      assert tier == Companies.get_tier!(tier.id)
    end

    test "delete_tier/1 deletes the tier" do
      tier = tier_fixture()
      assert {:ok, %Tier{}} = Companies.delete_tier(tier)
      assert_raise Ecto.NoResultsError, fn -> Companies.get_tier!(tier.id) end
    end

    test "change_tier/1 returns a tier changeset" do
      tier = tier_fixture()
      assert %Ecto.Changeset{} = Companies.change_tier(tier)
    end
  end
end
