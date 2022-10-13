defmodule Safira.AccountsTest do
  use Safira.DataCase

  alias Safira.Repo
  alias Safira.Accounts

  describe "list_users/0" do
    test "no users" do
      assert Accounts.list_users() == []
    end

    test "multiple users" do
      [user1, user2] = create_user_strategy_pair(:user)

      user1 =
        user1
        |> set_password_as_nil()

      user2 =
        user2
        |> set_password_as_nil()

      assert Accounts.list_users() == [user1, user2]
    end
  end

  describe "get_user!/1" do
    test "user exists" do
      user = create_user_strategy(:user)

      user =
        user
        |> set_password_as_nil()

      assert Accounts.get_user!(user.id) == user
    end

    test "user does not exist" do
      user = create_user_strategy(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id + 1) end
    end
  end

  describe "get_user_preload/1" do
    test "user exists" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)

      user =
        user
        |> set_password_as_nil()
        |> Repo.preload([:attendee, :company, :manager])

      assert Accounts.get_user_preload!(user.id) == user
    end

    test "user does not exist" do
      user = create_user_strategy(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_preload!(user.id + 1) end
    end
  end

  describe "get_user_email/1" do
    test "user with that email exists" do
      user = create_user_strategy(:user)

      user =
        user
        |> set_password_as_nil()

      assert Accounts.get_user_email(user.email) == user
    end

    test "user with that email does not exist" do
      assert Accounts.get_user_email("wrong_email@mail.com") |> is_nil()
    end
  end

  describe "get_user_preload_email!/1" do
    test "user with email exists" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)

      user =
        user
        |> set_password_as_nil()
        |> Repo.preload([:attendee, :company, :manager])

      assert Accounts.get_user_preload_email!(user.email) == user
    end

    test "user does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_preload_email!("wrong_email@mail.com")
      end
    end
  end

  describe "get_user_preload_email/1" do
    test "user with email exists" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)

      user =
        user
        |> set_password_as_nil()
        |> Repo.preload([:attendee, :company, :manager])

      assert Accounts.get_user_preload_email(user.email) == user
    end

    test "user does not exist" do
      assert Accounts.get_user_preload_email("wrong_email@mail.com") |> is_nil
    end
  end

  describe "create_user/1" do
    test "with valid data" do
      {:ok, user} =
        params_for(:user)
        |> Accounts.create_user()

      user =
        user
        |> set_password_as_nil()

      assert Accounts.list_users() == [user]
    end

    test "with invalid data" do
      {:error, _changeset} =
        params_for(:user, email: "invalid_email")
        |> Accounts.create_user()

      assert Accounts.list_users() == []
    end
  end

  describe "update_user/1" do
    test "with valid data" do
      user1 = create_user_strategy(:user)

      {:ok, user2} =
        user1
        |> Accounts.update_user(params_for(:user))

      user2 =
        user2
        |> set_password_as_nil()

      assert Accounts.list_users() == [user2]
    end

    test "with invalid data" do
      user = create_user_strategy(:user)

      {:error, _changeset} =
        user
        |> Accounts.update_user(params_for(:user, email: "invalid_email"))

      user =
        user
        |> set_password_as_nil()

      assert Accounts.list_users() == [user]
    end
  end

  describe "delete_user/1" do
    test "user exists" do
      user = create_user_strategy(:user)

      {:ok, _user} = Accounts.delete_user(user)

      assert Accounts.list_users() == []
    end
  end

  describe "list_attendees/0" do
    test "no attendees" do
      assert Accounts.list_attendees() == []
    end

    test "multiple attendees" do
      attendees = insert_list(3, :attendee)
      list = Accounts.list_attendees()

      for i <- 0..2 do
        assert Enum.at(attendees, i).id == Enum.at(list, i).id
      end
    end
  end

  describe "list_active_attendees/0" do
    test "no attendees" do
      assert Accounts.list_active_attendees() == []
    end

    test "multiple attendees" do
      attendees = insert_list(3, :attendee)
      list = Accounts.list_active_attendees()

      for i <- 0..2 do
        assert Enum.at(attendees, i).id == Enum.at(list, i).id
      end
    end

    test "inactive attendee" do
      insert(:attendee, user: nil)

      assert Accounts.list_active_attendees() == []
    end
  end

  describe "list_active_volunteers_attendees/0" do
    test "no attendees" do
      assert Accounts.list_active_volunteers_attendees() == []
    end

    test "multiple volunteer attendees" do
      attendees = insert_list(3, :attendee, volunteer: true)
      list = Accounts.list_active_volunteers_attendees()

      for i <- 0..2 do
        assert Enum.at(attendees, i).id == Enum.at(list, i).id
      end
    end

    test "one voluteer attendee" do
      volunteer = insert(:attendee, volunteer: true)
      insert_list(2, :attendee, volunteer: false)
      list = Accounts.list_active_volunteers_attendees()

      assert length(list) == 1
      assert Enum.at(list, 0).id == volunteer.id
    end
  end

  describe "get_attendee!/1" do
    test "attendee exists" do
      attendee = insert(:attendee)

      assert Accounts.get_attendee!(attendee.id).id == attendee.id
    end

    test "attendee does not exist" do
      insert(:attendee)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_attendee!(Ecto.UUID.generate()) end
    end
  end

  describe "get_attendee_with_badge_count!/1" do
    test "attendee exists" do
      badges = insert_list(3, :badge)
      attendee = insert(:attendee, badges: badges)

      attendee_with_badge_count = Accounts.get_attendee_with_badge_count!(attendee.id)

      assert attendee_with_badge_count.id == attendee.id
      assert attendee_with_badge_count.badge_count == 3
    end

    test "one badge of type 0" do
      badge = insert(:badge, type: 0)
      badges = insert_pair(:badge)
      badges = Enum.concat(badges, [badge])
      attendee = insert(:attendee, badges: badges)

      attendee_with_badge_count = Accounts.get_attendee_with_badge_count!(attendee.id)

      assert attendee_with_badge_count.id == attendee.id
      assert attendee_with_badge_count.badge_count == 2
    end

    test "attendee does not exist" do
      assert Accounts.get_attendee_with_badge_count!(Ecto.UUID.generate()) |> is_nil()
    end
  end

  describe "get_attendee/1" do
    test "attendee exists" do
      attendee = insert(:attendee)

      assert Accounts.get_attendee!(attendee.id).id == attendee.id
    end
  end

  describe "create_attendee/1" do
    test "with valid data" do
      {:ok, attendee} =
        params_for(:attendee)
        |> Accounts.create_attendee()

      assert Accounts.list_attendees() == [attendee]
    end

    test "with invalid data" do
      {:error, _changeset} =
        params_for(:attendee, nickname: "more_than_fifteen_chars")
        |> Accounts.create_attendee()

      assert Accounts.list_attendees() == []
    end
  end

  describe "update_attendee/1" do
    test "with valid data" do
      attendee1 = insert(:attendee)

      {:ok, attendee2} =
        attendee1
        |> Accounts.update_attendee(params_for(:attendee))

      attendee2 =
        attendee2
        |> forget(:user)

      assert Accounts.list_attendees() == [attendee2]
    end

    test "with invalid data" do
      attendee = insert(:attendee)

      {:error, _changeset} =
        attendee
        |> Accounts.update_attendee(params_for(:attendee, nickname: "more_than_fifteen_chars"))

      attendee =
        attendee
        |> forget(:user)

      assert Accounts.list_attendees() == [attendee]
    end
  end

  describe "delete_attendee/1" do
    test "attendee exists" do
      attendee = insert(:attendee)

      {:ok, _attendee} = Accounts.delete_attendee(attendee)

      assert Accounts.list_attendees() == []
    end
  end

  describe "is_volunteer/1" do
    test "attendee is volunteer" do
      attendee = insert(:attendee, volunteer: true)

      assert Accounts.is_volunteer(attendee) == true
    end

    test "attendee is not a volunteer" do
      attendee = insert(:attendee, volunteer: false)

      assert Accounts.is_volunteer(attendee) == false
    end
  end

  describe "list_managers/0" do
    test "no managers" do
      assert Accounts.list_managers() == []
    end

    test "multiple managers" do
      [manager1, manager2] = insert_pair(:manager)

      manager1 =
        manager1
        |> forget(:user)

      manager2 =
        manager2
        |> forget(:user)

      assert Accounts.list_managers() == [manager1, manager2]
    end
  end

  describe "get_manager!/1" do
    test "manager exists" do
      manager = insert(:manager)

      manager =
        manager
        |> forget(:user)

      assert Accounts.get_manager!(manager.id) == manager
    end

    test "user does not exist" do
      manager = insert(:manager)

      manager =
        manager
        |> forget(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_manager!(manager.id + 1) end
    end
  end

  describe "get_manager_by_email/1" do
    test "user with that email exists" do
      manager = insert(:manager)

      assert Enum.at(Accounts.get_manager_by_email(manager.user.email), 0).id == manager.id
    end

    test "user with that email does not exist" do
      assert Accounts.get_manager_by_email("wrong_email@mail.com") == []
    end
  end

  describe "create_manager/1" do
    test "with valid data" do
      {:ok, manager} =
        params_for(:manager)
        |> Accounts.create_manager()

      assert Accounts.list_managers() == [manager]
    end
  end

  describe "update_manager/1" do
    test "with valid data" do
      manager1 = insert(:manager)

      {:ok, manager2} =
        manager1
        |> Accounts.update_manager(params_for(:manager))

      manager2 =
        manager2
        |> forget(:user)

      assert Accounts.list_managers() == [manager2]
    end
  end

  describe "delete_manager/1" do
    test "user exists" do
      manager = insert(:manager)

      {:ok, _manager} = Accounts.delete_manager(manager)

      assert Accounts.list_managers() == []
    end
  end

  describe "list_companies/0" do
    test "no companies" do
      assert Accounts.list_companies() == []
    end

    test "multiple companies" do
      [company1, company2] = insert_pair(:company)

      company1 =
        company1
        |> forget(:user)
        |> forget(:badge)

      company2 =
        company2
        |> forget(:user)
        |> forget(:badge)

      assert Accounts.list_companies() == [company1, company2]
    end
  end

  describe "get_company!/1" do
    test "company exists" do
      company = insert(:company)

      assert Accounts.get_company!(company.id).id == company.id
    end

    test "attendee does not exist" do
      insert(:company)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_company!(123) end
    end
  end

  describe "create_company/1" do
    test "with valid data" do
      badge = insert(:badge)

      {:ok, company} =
        params_for(:company, badge: badge)
        |> Accounts.create_company()

      assert Accounts.list_companies() == [company]
    end

    test "with invalid data" do
      {:error, _changeset} =
        params_for(:company)
        |> Accounts.create_company()

      assert Accounts.list_companies() == []
    end
  end

  describe "delete_company/1" do
    test "company exists" do
      company = insert(:company)

      {:ok, _company} = Accounts.delete_company(company)

      assert Accounts.list_companies() == []
    end
  end

  defp set_password_as_nil(user) do
    user
    |> Map.put(:password, nil)
    |> Map.put(:password_confirmation, nil)
  end

  defp forget(struct, field, cardinality \\ :one) do
    %{
      struct
      | field => %Ecto.Association.NotLoaded{
          __field__: field,
          __owner__: struct.__struct__,
          __cardinality__: cardinality
        }
    }
  end
end
