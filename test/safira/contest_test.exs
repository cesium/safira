defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  ###############################################################
  ###############################################################
  ################           BADGES            ##################
  ###############################################################
  ###############################################################

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

  ###############################################################
  ###############################################################
  ################          REFERRAL           ##################
  ###############################################################
  ###############################################################

  describe "list_referrals/0" do
    test "no referrals" do
      assert Contest.list_referrals() == []
    end

    test "multiple referrals" do
      r1 = insert(:referral)
      r2 = insert(:referral)

      assert Contest.list_referrals() |> Repo.preload(:badge) == [r1, r2]
    end
  end

  describe "get_referral!/1" do
    test "exists" do
      r1 = insert(:referral)
      assert Contest.get_referral!(r1.id) |> Repo.preload(:badge) == r1
    end

    test "doesn't exist" do
      r1 = insert(:referral)

      assert_raise Ecto.NoResultsError, fn -> Contest.get_referral!(Ecto.UUID.generate()) end
    end
  end

  describe "get_referral_preload!/1" do
    test "exists" do
      r1 = insert(:referral)
      assert Contest.get_referral_preload!(r1.id) == r1
    end

    test "doesn't exist" do
      r1 = insert(:referral)

      assert_raise Ecto.NoResultsError, fn -> Contest.get_referral_preload!(Ecto.UUID.generate()) end
    end
  end

  describe "create_referral/1" do
    test "exists" do
      badge = insert(:badge)
      {:ok, referral} = Contest.create_referral(params_for(:referral, badge_id: badge.id))
      assert Contest.list_referrals() == [referral]
    end

    test "doesn't exist" do
      r1 = insert(:referral)

      assert_raise Ecto.NoResultsError, fn -> Contest.get_referral_preload!(Ecto.UUID.generate()) end
    end
  end

  describe "update_referral/1" do
    test "valid data" do
      r1 = insert(:referral)
      {:ok, r2} = Contest.update_referral(r1, params_for(:referral))
      assert Contest.get_referral_preload!(r1.id) == r2
    end

    test "invalid data" do
      r1 = insert(:referral)

      {:error, _changeset} = Contest.update_referral(r1, params_for(:referral, badge_id: Ecto.UUID.generate()))
      assert Contest.get_referral_preload!(r1.id) == r1
    end
  end

  describe "delete_referral/1" do
    test "Valid data" do
      r = insert(:referral)
      {:ok, _r} = Contest.delete_referral(r)
      assert Contest.list_referrals() == []
    end
  end

  describe "change_referral/1" do
    test "Valid data" do
      referral = insert(:referral)
      assert %Ecto.Changeset{} = Contest.change_referral(referral)
    end
  end

  ###############################################################
  ###############################################################
  ################           REDEEM            ##################
  ###############################################################
  ###############################################################

  describe "list_redeems/0" do
    test "no redeems" do
      assert Contest.list_redeems() == []
    end

    test "multiple redeems" do
      r1 = insert(:redeem)
      r2 = insert(:redeem)

      assert Contest.list_redeems() |> Enum.map(fn x -> x.id end) == [r1.id, r2.id]
    end
  end

  describe "list_redeems_stats/0" do
    test "no redeems" do
      assert Contest.list_redeems_stats() == []
    end

    test "multiple redeems" do
      at = insert(:attendee, volunteer: false)
      b  = insert(:badge, type: 1)
      r1 = insert(:redeem, attendee: at, badge: b)

      assert Contest.list_redeems_stats() |> Enum.map(fn x -> x.id end) == [r1.id]
    end
  end

  describe "get_redeem!/1" do
    test "exists" do
      r1 = insert(:redeem)

      assert Contest.get_redeem!(r1.id).id == r1.id
    end

    test "doesn't exist" do
      r1 = insert(:redeem)

      assert_raise Ecto.NoResultsError, fn -> Contest.get_redeem!(r1.id + 1) end
    end
  end

  describe "get_keys_redeem/2" do
    test "exists" do
      r1 = insert(:redeem)

      assert Contest.get_keys_redeem(r1.attendee.id, r1.badge.id).id == r1.id
    end

    test "doesn't exist (attendee)" do
      r1 = insert(:redeem)

      assert is_nil(Contest.get_keys_redeem(Ecto.UUID.generate(), r1.badge.id))
    end

    test "doesn't exist (badge)" do
      r1 = insert(:redeem)

      assert is_nil(Contest.get_keys_redeem(r1.attendee.id, r1.badge.id + 1))
    end
  end

  describe "get_keys_daily_token/2" do
    test "exists" do
      dt = insert(:daily_token)

      assert Contest.get_keys_daily_token(dt.attendee.id, dt.day).id == dt.id
    end

    test "doesn't exist (attendee)" do
      dt = insert(:daily_token)

      assert is_nil(Contest.get_keys_daily_token(Ecto.UUID.generate(), dt.day))
    end

    test "doesn't exist (day)" do
      dt = insert(:daily_token)

      assert is_nil(Contest.get_keys_daily_token(dt.attendee.id, Faker.DateTime.forward(2000)))
    end
  end

  describe "create_redeem/1" do
    alias Safira.Accounts

    test "valid data" do
      at = insert(:attendee)
      b  = insert(:badge)
      {:ok, redeem} = Contest.create_redeem(params_for(:redeem, attendee: at, badge: b))

      assert Contest.get_redeem!(redeem.id) == redeem
      assert at.token_balance + b.tokens == Accounts.get_attendee!(at.id).token_balance
    end

    test "invalid data (too soon for badge)" do
      d1 = Faker.DateTime.forward(10)
      d2 = Faker.DateTime.forward(2)
      at = insert(:attendee)

      if DateTime.compare(d1, d2) == :gt do
        b = insert(:badge, begin_badge: d2, end_badge: d1)
        {:error, _changeset} = Contest.create_redeem(params_for(:redeem, attendee: at, badge: b))

        assert Contest.list_redeems() == []
        assert at.token_balance == Accounts.get_attendee!(at.id).token_balance
      else
        b = insert(:badge, begin_badge: d1, end_badge: d2)
        {:error, _changeset} = Contest.create_redeem(params_for(:redeem, attendee: at, badge: b))

        assert Contest.list_redeems() == []
        assert at.token_balance == Accounts.get_attendee!(at.id).token_balance
      end
    end

    test "invalid data (too late for badge)" do
      d1 = Faker.DateTime.backward(10)
      d2 = Faker.DateTime.backward(2)
      at = insert(:attendee)

      if DateTime.compare(d1, d2) == :gt do
        b = insert(:badge, begin_badge: d2, end_badge: d1)
        {:error, _changeset} = Contest.create_redeem(params_for(:redeem, attendee: at, badge: b))

        assert Contest.list_redeems() == []
        assert at.token_balance == Accounts.get_attendee!(at.id).token_balance
      else
        b = insert(:badge, begin_badge: d1, end_badge: d2)
        {:error, _changeset} = Contest.create_redeem(params_for(:redeem, attendee: at, badge: b))

        assert Contest.list_redeems() == []
        assert at.token_balance == Accounts.get_attendee!(at.id).token_balance
      end
    end
  end

  describe "update_redeem/2" do
    test "valid data" do
      b1 = insert(:badge, type: 4)
      b2 = insert(:badge, type: 4)
      r1 = insert(:redeem, badge: b1)
      {:ok, r2} = Contest.update_redeem(r1, params_for(:redeem, badge: b2))

      assert Contest.get_redeem!(r1.id).id == r2.id
    end

    test "invalid data" do
      b1 = insert(:badge, type: 7)
      b2 = insert(:badge, type: 7)
      at = insert(:attendee)
      r1 = insert(:redeem, badge: b1, attendee: at)

      {:error, _changeset} = Contest.update_redeem(r1, params_for(:redeem, badge: b2, attendee: at))

      assert (Contest.get_redeem!(r1.id) |> Repo.preload(:badge)).badge == b1
    end
  end

  describe "delete_redeem/1" do
    test "valid data" do
      r1 = insert(:redeem)
      Contest.delete_redeem(r1)

      assert Contest.list_redeems() == []
    end
  end

  describe "change_redeem/1" do
    test "valid data" do
      r1 = insert(:redeem)

      assert %Ecto.Changeset{} = Contest.change_redeem(r1)
    end
  end
end
