defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  describe "referrals" do
    alias Safira.Contest.Referral

    @valid_attrs %{available: true}
    @update_attrs %{available: false}
    @invalid_attrs %{available: nil}

    def referral_fixture(attrs \\ %{}) do
      {:ok, referral} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contest.create_referral()

      referral
    end

    test "list_referrals/0 returns all referrals" do
      referral = referral_fixture()
      assert Contest.list_referrals() == [referral]
    end

    test "get_referral!/1 returns the referral with given id" do
      referral = referral_fixture()
      assert Contest.get_referral!(referral.id) == referral
    end

    test "create_referral/1 with valid data creates a referral" do
      assert {:ok, %Referral{} = referral} = Contest.create_referral(@valid_attrs)
      assert referral.available == true
    end

    test "create_referral/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contest.create_referral(@invalid_attrs)
    end

    test "update_referral/2 with valid data updates the referral" do
      referral = referral_fixture()
      assert {:ok, referral} = Contest.update_referral(referral, @update_attrs)
      assert %Referral{} = referral
      assert referral.available == false
    end

    test "update_referral/2 with invalid data returns error changeset" do
      referral = referral_fixture()
      assert {:error, %Ecto.Changeset{}} = Contest.update_referral(referral, @invalid_attrs)
      assert referral == Contest.get_referral!(referral.id)
    end

    test "delete_referral/1 deletes the referral" do
      referral = referral_fixture()
      assert {:ok, %Referral{}} = Contest.delete_referral(referral)
      assert_raise Ecto.NoResultsError, fn -> Contest.get_referral!(referral.id) end
    end

    test "change_referral/1 returns a referral changeset" do
      referral = referral_fixture()
      assert %Ecto.Changeset{} = Contest.change_referral(referral)
    end
  end
end
