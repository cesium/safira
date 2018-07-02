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
end
