defmodule Safira.AccountsTest do
  use Safira.DataCase

  alias Safira.Accounts
  alias Safira.Repo

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
        |> Repo.preload([:attendee, :company, :staff])

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
        |> Repo.preload([:attendee, :company, :staff])

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
        |> Repo.preload([:attendee, :company, :staff])

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

      attendee_with_badge_count = Accounts.get_attendee_with_badge_count_by_id!(attendee.id)

      assert attendee_with_badge_count.id == attendee.id
      assert attendee_with_badge_count.badge_count == 3
    end

    test "one badge of type 0" do
      badge = insert(:badge, type: 0)
      badges = insert_pair(:badge)
      badges = Enum.concat(badges, [badge])
      attendee = insert(:attendee, badges: badges)

      attendee_with_badge_count = Accounts.get_attendee_with_badge_count_by_id!(attendee.id)

      assert attendee_with_badge_count.id == attendee.id
      assert attendee_with_badge_count.badge_count == 2
    end

    test "attendee does not exist" do
      assert Accounts.get_attendee_with_badge_count_by_id!(Ecto.UUID.generate()) |> is_nil()
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

  describe "list_staffs/0" do
    test "no staffs" do
      assert Accounts.list_staffs() == []
    end

    test "multiple staffs" do
      [staff1, staff2] = insert_pair(:staff)

      staff1 =
        staff1
        |> forget(:user)

      staff2 =
        staff2
        |> forget(:user)

      assert Accounts.list_staffs() == [staff1, staff2]
    end
  end

  describe "get_staff!/1" do
    test "staff exists" do
      staff = insert(:staff)

      staff =
        staff
        |> forget(:user)

      assert Accounts.get_staff!(staff.id) == staff
    end

    test "user does not exist" do
      staff = insert(:staff)

      staff =
        staff
        |> forget(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_staff!(staff.id + 1) end
    end
  end

  describe "get_staff_by_email/1" do
    test "user with that email exists" do
      staff = insert(:staff)

      assert Enum.at(Accounts.get_staff_by_email(staff.user.email), 0).id == staff.id
    end

    test "user with that email does not exist" do
      assert Accounts.get_staff_by_email("wrong_email@mail.com") == []
    end
  end

  describe "create_staff/1" do
    test "with valid data" do
      {:ok, staff} =
        params_for(:staff)
        |> Accounts.create_staff()

      assert Accounts.list_staffs() == [staff]
    end
  end

  describe "update_staff/1" do
    test "with valid data" do
      staff1 = insert(:staff)

      {:ok, staff2} =
        staff1
        |> Accounts.update_staff(params_for(:staff))

      staff2 =
        staff2
        |> forget(:user)

      assert Accounts.list_staffs() == [staff2]
    end
  end

  describe "delete_staff/1" do
    test "user exists" do
      staff = insert(:staff)

      {:ok, _staff} = Accounts.delete_staff(staff)

      assert Accounts.list_staffs() == []
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

  describe "list_company_attendees" do
    test "no attendees" do
      company = insert(:company)

      assert Accounts.list_company_attendees(company.id) == []
    end

    test "one attendee" do
      company = insert(:company)
      attendee = insert(:attendee)

      insert(:redeem, attendee: attendee, badge: company.badge)

      attendee =
        attendee
        |> forget(:user)

      assert Accounts.list_company_attendees(company.id) == [attendee |> Repo.preload(:user)]
    end

    test "multiple attendees" do
      company = insert(:company)
      [attendee1, attendee2] = insert_pair(:attendee)

      insert(:redeem, attendee: attendee1, badge: company.badge)
      insert(:redeem, attendee: attendee2, badge: company.badge)

      attendee1 =
        attendee1
        |> forget(:user)

      attendee2 =
        attendee2
        |> forget(:user)

      assert Accounts.list_company_attendees(company.id) == [
               attendee1 |> Repo.preload(:user),
               attendee2 |> Repo.preload(:user)
             ]
    end

    test "attendee redeemed another Bronze company's badge" do
      company = insert(:company, sponsorship: "Bronze")
      attendee = insert(:attendee)

      insert(:redeem, attendee: attendee)

      assert Accounts.list_company_attendees(company.id) == []
    end

    test "one attendee redeemed and one not" do
      company = insert(:company, sponsorship: "Bronze")
      [attendee1, attendee2] = insert_pair(:attendee)

      insert(:redeem, attendee: attendee1, badge: company.badge)
      insert(:redeem, attendee: attendee2)

      attendee1 =
        attendee1
        |> forget(:user)

      assert Accounts.list_company_attendees(company.id) == [attendee1 |> Repo.preload(:user)]
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
