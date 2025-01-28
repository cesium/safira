defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  describe "badge_redeems" do
    alias Safira.Contest.BadgeRedeem

    import Safira.ContestFixtures

    @invalid_attrs %{}

    test "list_badge_redeems/0 returns all badge_redeems" do
      badge_redeem = badge_redeem_fixture()
      assert Contest.list_badge_redeems() == [badge_redeem]
    end

    test "get_badge_redeem!/1 returns the badge_redeem with given id" do
      badge_redeem = badge_redeem_fixture()
      assert Contest.get_badge_redeem!(badge_redeem.id) == badge_redeem
    end

    test "create_badge_redeem/1 with valid data creates a badge_redeem" do
      valid_attrs = %{}

      assert {:ok, %BadgeRedeem{} = badge_redeem} = Contest.create_badge_redeem(valid_attrs)
    end

    test "create_badge_redeem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contest.create_badge_redeem(@invalid_attrs)
    end

    test "update_badge_redeem/2 with valid data updates the badge_redeem" do
      badge_redeem = badge_redeem_fixture()
      update_attrs = %{}

      assert {:ok, %BadgeRedeem{} = badge_redeem} =
               Contest.update_badge_redeem(badge_redeem, update_attrs)
    end

    test "update_badge_redeem/2 with invalid data returns error changeset" do
      badge_redeem = badge_redeem_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contest.update_badge_redeem(badge_redeem, @invalid_attrs)

      assert badge_redeem == Contest.get_badge_redeem!(badge_redeem.id)
    end

    test "delete_badge_redeem/1 deletes the badge_redeem" do
      badge_redeem = badge_redeem_fixture()
      assert {:ok, %BadgeRedeem{}} = Contest.delete_badge_redeem(badge_redeem)
      assert_raise Ecto.NoResultsError, fn -> Contest.get_badge_redeem!(badge_redeem.id) end
    end

    test "change_badge_redeem/1 returns a badge_redeem changeset" do
      badge_redeem = badge_redeem_fixture()
      assert %Ecto.Changeset{} = Contest.change_badge_redeem(badge_redeem)
    end
  end
end
