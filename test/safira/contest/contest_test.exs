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

  describe "redeems" do
    alias Safira.Contest.Redeem

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def redeem_fixture(attrs \\ %{}) do
      {:ok, redeem} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contest.create_redeem()

      redeem
    end

    test "list_redeems/0 returns all redeems" do
      redeem = redeem_fixture()
      assert Contest.list_redeems() == [redeem]
    end

    test "get_redeem!/1 returns the redeem with given id" do
      redeem = redeem_fixture()
      assert Contest.get_redeem!(redeem.id) == redeem
    end

    test "create_redeem/1 with valid data creates a redeem" do
      assert {:ok, %Redeem{} = redeem} = Contest.create_redeem(@valid_attrs)
    end

    test "create_redeem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contest.create_redeem(@invalid_attrs)
    end

    test "update_redeem/2 with valid data updates the redeem" do
      redeem = redeem_fixture()
      assert {:ok, redeem} = Contest.update_redeem(redeem, @update_attrs)
      assert %Redeem{} = redeem
    end

    test "update_redeem/2 with invalid data returns error changeset" do
      redeem = redeem_fixture()
      assert {:error, %Ecto.Changeset{}} = Contest.update_redeem(redeem, @invalid_attrs)
      assert redeem == Contest.get_redeem!(redeem.id)
    end

    test "delete_redeem/1 deletes the redeem" do
      redeem = redeem_fixture()
      assert {:ok, %Redeem{}} = Contest.delete_redeem(redeem)
      assert_raise Ecto.NoResultsError, fn -> Contest.get_redeem!(redeem.id) end
    end

    test "change_redeem/1 returns a redeem changeset" do
      redeem = redeem_fixture()
      assert %Ecto.Changeset{} = Contest.change_redeem(redeem)
    end
  end
end
