defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  describe "badges" do
    alias Safira.Contest.Badge

    @valid_attrs %{begin: "2010-04-17 14:00:00.000000Z", end: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{begin: "2011-05-18 15:01:01.000000Z", end: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{begin: nil, end: nil}

    def badge_fixture(attrs \\ %{}) do
      {:ok, badge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contest.create_badge()

      badge
    end

    test "list_badges/0 returns all badges" do
      badge = badge_fixture()
      assert Contest.list_badges() == [badge]
    end

    test "get_badge!/1 returns the badge with given id" do
      badge = badge_fixture()
      assert Contest.get_badge!(badge.id) == badge
    end

    test "create_badge/1 with valid data creates a badge" do
      assert {:ok, %Badge{} = badge} = Contest.create_badge(@valid_attrs)
      assert badge.begin == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert badge.end == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_badge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contest.create_badge(@invalid_attrs)
    end

    test "update_badge/2 with valid data updates the badge" do
      badge = badge_fixture()
      assert {:ok, badge} = Contest.update_badge(badge, @update_attrs)
      assert %Badge{} = badge
      assert badge.begin == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert badge.end == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_badge/2 with invalid data returns error changeset" do
      badge = badge_fixture()
      assert {:error, %Ecto.Changeset{}} = Contest.update_badge(badge, @invalid_attrs)
      assert badge == Contest.get_badge!(badge.id)
    end

    test "delete_badge/1 deletes the badge" do
      badge = badge_fixture()
      assert {:ok, %Badge{}} = Contest.delete_badge(badge)
      assert_raise Ecto.NoResultsError, fn -> Contest.get_badge!(badge.id) end
    end

    test "change_badge/1 returns a badge changeset" do
      badge = badge_fixture()
      assert %Ecto.Changeset{} = Contest.change_badge(badge)
    end
  end

  describe "users_badges" do
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

    test "list_users_badges/0 returns all users_badges" do
      redeem = redeem_fixture()
      assert Contest.list_users_badges() == [redeem]
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
