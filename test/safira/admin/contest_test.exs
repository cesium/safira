defmodule Safira.Admin.ContestTest do
  use Safira.DataCase

  alias Safira.Admin.Contest

  describe "badges" do
    alias Safira.Admin.Contest.Badge

    @valid_attrs %{begin: "2010-04-17T14:00:00Z", description: "some description", end: "2010-04-17T14:00:00Z", name: "some name", type: 42}
    @update_attrs %{begin: "2011-05-18T15:01:01Z", description: "some updated description", end: "2011-05-18T15:01:01Z", name: "some updated name", type: 43}
    @invalid_attrs %{begin: nil, description: nil, end: nil, name: nil, type: nil}

    def badge_fixture(attrs \\ %{}) do
      {:ok, badge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contest.create_badge()

      badge
    end

    test "paginate_badges/1 returns paginated list of badges" do
      for _ <- 1..20 do
        badge_fixture()
      end

      {:ok, %{badges: badges} = page} = Contest.paginate_badges(%{})

      assert length(badges) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
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
      assert badge.begin == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert badge.description == "some description"
      assert badge.end == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert badge.name == "some name"
      assert badge.type == 42
    end

    test "create_badge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contest.create_badge(@invalid_attrs)
    end

    test "update_badge/2 with valid data updates the badge" do
      badge = badge_fixture()
      assert {:ok, badge} = Contest.update_badge(badge, @update_attrs)
      assert %Badge{} = badge
      assert badge.begin == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert badge.description == "some updated description"
      assert badge.end == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert badge.name == "some updated name"
      assert badge.type == 43
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
