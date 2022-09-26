defmodule Safira.AccountsTest do
  use Safira.DataCase

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

    test "user does not exists" do
      user = create_user_strategy(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id + 1) end
    end
  end

  describe "get_user_preload/1" do
    test "user exists" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

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
      attendee = insert(:attendee, user: user)

      user =
        user
        |> set_password_as_nil()
        |> Repo.preload([:attendee, :company, :manager])

      assert Accounts.get_user_preload_email!(user.email) == user
    end

    test "user does not exist" do
      user = create_user_strategy(:user)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_preload_email!("wrong_email@mail.com") end
    end
  end

  describe "get_user_preload_email/1" do
    test "user with email exists" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      user =
        user
        |> set_password_as_nil()
        |> Repo.preload([:attendee, :company, :manager])

      assert Accounts.get_user_preload_email(user.email) == user
    end

    test "user does not exist" do
      user = create_user_strategy(:user)

      assert Accounts.get_user_preload_email("wrong_email@mail.com") |> is_nil
    end
  end

  defp set_password_as_nil(user) do
    user =
      user
      |> Map.put(:password, nil)
      |> Map.put(:password_confirmation, nil)
  end
end
