defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  describe "list_badges/0" do
    test "no badges" do
      assert Contest.list_badges() == []
    end

    test "multiple badges" do
      badge = insert(:badge)
      assert Contest.list_badges() == [badge]
    end
  end

  describe "list_available_badges/0" do
    test "no badges" do
      assert Contest.list_available_badges() == []
    end

    test "multiple badges" do
      b0 = insert(:badge, type: 0)
      b1 = insert(:badge, type: 1)
      b2 = insert(:badge, type: 2)
      b3 = insert(:badge, type: 3)
      b4 = insert(:badge, type: 4)
      b5 = insert(:badge, type: 3, begin_badge: Faker.DateTime.forward(2))
      assert Contest.list_available_badges() == [b0, b1, b2, b3]
    end
  end

  describe "list_normals/0" do
    test "no badges" do
      assert Contest.list_normals() == []
    end

    test "multiple badges" do
      b2 = insert(:badge, type: 2)
      b3 = insert(:badge, type: 3)
      b4 = insert(:badge, type: 4)
      b5 = insert(:badge, type: 3, begin_badge: Faker.DateTime.forward(2))
      assert Contest.list_normals() == [b2, b3, b4, b5]
    end
  end

  describe "list_secret/0" do
    test "no redeems" do
      assert Contest.list_secret() == []
    end

    test "multiple badges" do
      b1 = insert(:badge, type: 1)
      b2 = insert(:badge, type: 2)
      a1 = insert(:attendee, volunteer: false)
      a2 = insert(:attendee, volunteer: true)
      r1 = insert(:redeem, badge: b1, attendee: a1)
      r2 = insert(:redeem, badge: b1, attendee: a2)
      r3 = insert(:redeem, badge: b2)

      assert Contest.list_secret() == [b1]
    end
  end

  describe "list_badges_conservative/0" do
    test "nothing" do
      assert Contest.list_badges_conservative() == []
    end

    test "multiple badges" do
      b1 = insert(:badge, type: 1)
      b2 = insert(:badge, type: 2)
      b3 = insert(:badge, type: 3)
      b4 = insert(:badge, type: 4)
      b5 = insert(:badge, type: 3, begin_badge: Faker.DateTime.forward(2))
      a1 = insert(:attendee, volunteer: false)
      a2 = insert(:attendee, volunteer: true)
      r1 = insert(:redeem, badge: b1, attendee: a1)
      r2 = insert(:redeem, badge: b1, attendee: a2)
      r3 = insert(:redeem, badge: b2)

      assert Contest.list_badges_conservative() == [b1, b2, b3, b4, b5]
    end
  end

  describe "get_badge!/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Contest.get_badge!(nil)
      end
    end

    test "Wrong id" do
      badge = insert(:badge)

      assert_raise Ecto.NoResultsError, fn ->
        Contest.get_badge!(badge.id + 1)
      end
    end

    test "Exists" do
      badge = insert(:badge)
      assert Contest.get_badge!(badge.id) == badge
    end
  end

  describe "get_badge_name!/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Contest.get_badge_name!(nil)
      end
    end

    test "Wrong name" do
      badge = insert(:badge)

      assert_raise Ecto.NoResultsError, fn ->
        Contest.get_badge_name!("wrong name")
      end
    end

    test "Exists" do
      badge = insert(:badge)
      assert Contest.get_badge_name!(badge.name) == badge
    end
  end

  describe "get_badge_preload!/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Contest.get_badge_preload!(nil)
      end
    end

    test "Wrong id" do
      badge = insert(:badge)

      assert_raise Ecto.NoResultsError, fn ->
        Contest.get_badge_preload!(badge.id + 1)
      end
    end

    test "Exists" do
      a1 = insert(:attendee)
      a2 = insert(:attendee)
      a3 = insert(:attendee)

      badge = insert(:badge)
      insert(:redeem, badge: badge, attendee: a1)
      insert(:redeem, badge: badge, attendee: a3)

      assert Contest.get_badge_preload!(badge.id).attendees == [a1, a3]
    end
  end

  describe "get_badge_description/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Contest.get_badge_description!(nil)
      end
    end

    test "Wrong id" do
      badge = insert(:badge)

      assert_raise Ecto.NoResultsError, fn ->
        Contest.get_badge_description!(badge.id + 1)
      end
    end

    test "Exists" do
      badge = insert(:badge)
      assert Contest.get_badge_description!(badge.id) == badge.description
    end
  end

  describe "create_badge/1" do
    test "Valid data" do
      {:ok, badge} = Contest.create_badge(params_for(:badge))
      assert Contest.list_badges() == [badge]
    end

    test "Invalid data" do
      {:ok, badge} = Contest.create_badge(params_for(:badge, type: -1))
      assert Contest.list_badges() == []
    end
  end

end
