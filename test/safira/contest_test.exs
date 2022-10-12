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

      assert Contest.get_badge_preload!(badge.id).attendees
            |> Enum.map(fn x -> x.id end) == [a1.id, a3.id]
    end
  end

  describe "get_badge_description/1" do
    test "Nil" do
      assert_raise ArgumentError, fn ->
        Contest.get_badge_description(nil)
      end
    end

    test "Wrong id" do
      badge = insert(:badge)

      assert_raise Ecto.NoResultsError, fn ->
        Contest.get_badge_description("No such badge")
      end
    end

    test "Exists" do
      badge = insert(:badge)
      assert Contest.get_badge_description(badge.description) == badge
    end
  end

  describe "create_badge/1" do
    test "Valid data" do
      {:ok, badge} = Contest.create_badge(params_for(:badge))
      assert Contest.list_badges() == [badge]
    end

    test "Invalid data" do
      {:error, _changeset} = Contest.create_badge(params_for(:badge, begin: Faker.DateTime.forward(2), end: Faker.DateTime.backward(2)))
      assert Contest.list_badges() == []
    end
  end

  describe "create_badges/1" do
    test "Valid data" do
      Contest.create_badges([params_for(:badge), params_for(:badge)])
      |> Repo.transaction()
      assert length(Contest.list_badges()) == 2
    end

    test "Invalid data" do
      Contest.create_badges([params_for(:badge), params_for(:badge, begin: Faker.DateTime.forward(2), end: Faker.DateTime.backward(2))])
      |> Repo.transaction()
      assert Contest.list_badges() == []
    end
  end

  describe "update_badge/1" do
    test "Valid data" do
      badge = insert(:badge)
      {:ok, new_badge} = Contest.update_badge(badge, params_for(:badge))
      assert Contest.get_badge!(badge.id) == new_badge
    end

    test "Invalid data" do
      badge = insert(:badge)
      {:error, _changeset} = Contest.update_badge(badge,  params_for(:badge, begin: Faker.DateTime.forward(2), end: Faker.DateTime.backward(2)))
      assert Contest.get_badge!(badge.id) == badge
    end
  end

  describe "delete_badge/1" do
    test "Valid data" do
      badge = insert(:badge)
      {:ok, _badge} = Contest.delete_badge(badge)
      assert Contest.list_badges() == []
    end
  end

  describe "change_badge/1" do
    test "Valid data" do
      badge = insert(:badge)
      assert %Ecto.Changeset{} = Contest.change_badge(badge)
    end
  end

  describe "badge_is_in_time/1" do
    test "In time" do
      badge = insert(:badge)
      assert Contest.badge_is_in_time(badge)
    end

    test "Too late" do
      d1 = Faker.DateTime.backward(10)
      d2 = Faker.DateTime.backward(2)

      if DateTime.compare(d1, d2) == :gt do
        badge = insert(:badge, begin_badge: d2, end_badge: d1)
        assert not Contest.badge_is_in_time(badge)
      else
        badge = insert(:badge, begin_badge: d1, end_badge: d2)
        assert not Contest.badge_is_in_time(badge)
      end
    end

    test "Too early" do
      d1 = Faker.DateTime.forward(10)
      d2 = Faker.DateTime.forward(2)

      if DateTime.compare(d1, d2) == :gt do
        badge = insert(:badge, begin_badge: d2, end_badge: d1)
        assert not Contest.badge_is_in_time(badge)
      else
        badge = insert(:badge, begin_badge: d1, end_badge: d2)
        assert not Contest.badge_is_in_time(badge)
      end
    end
  end
end
