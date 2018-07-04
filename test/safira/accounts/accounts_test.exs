defmodule Safira.AccountsTest do
  use Safira.DataCase

  alias Safira.Accounts

  describe "users" do
    alias Safira.Accounts.User

    @valid_attrs %{email: "some@email", password: "some password", password_confirmation: "some password"}
    @update_attrs %{email: "some@updated.email", password: "some updated password", password_confirmation: "some updated password"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [%User{user | password: nil, password_confirmation: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == %User{user | password: nil, password_confirmation: nil}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email"
      assert Comeonin.Bcrypt.checkpw("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some@updated.email"
      assert Comeonin.Bcrypt.checkpw("some updated password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert %User{user | password: nil, password_confirmation: nil} == Accounts.get_user!(user.id)
      assert Comeonin.Bcrypt.checkpw("some password", user.password_hash)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "attendees" do
    alias Safira.Accounts.Attendee

    @valid_attrs %{nickname: "some nickname", uuid: "some uuid"}
    @update_attrs %{nickname: "some updated nickname", uuid: "some updated uuid"}
    @invalid_attrs %{nickname: nil, uuid: nil}

    def attendee_fixture(attrs \\ %{}) do
      {:ok, attendee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_attendee()

      attendee
    end

    test "list_attendees/0 returns all attendees" do
      attendee = attendee_fixture()
      assert Accounts.list_attendees() == [attendee]
    end

    test "get_attendee!/1 returns the attendee with given id" do
      attendee = attendee_fixture()
      assert Accounts.get_attendee!(attendee.id) == attendee
    end

    test "create_attendee/1 with valid data creates a attendee" do
      assert {:ok, %Attendee{} = attendee} = Accounts.create_attendee(@valid_attrs)
      assert attendee.nickname == "some nickname"
      assert attendee.uuid == "some uuid"
    end

    test "create_attendee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_attendee(@invalid_attrs)
    end

    test "update_attendee/2 with valid data updates the attendee" do
      attendee = attendee_fixture()
      assert {:ok, attendee} = Accounts.update_attendee(attendee, @update_attrs)
      assert %Attendee{} = attendee
      assert attendee.nickname == "some updated nickname"
      assert attendee.uuid == "some updated uuid"
    end

    test "update_attendee/2 with invalid data returns error changeset" do
      attendee = attendee_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_attendee(attendee, @invalid_attrs)
      assert attendee == Accounts.get_attendee!(attendee.id)
    end

    test "delete_attendee/1 deletes the attendee" do
      attendee = attendee_fixture()
      assert {:ok, %Attendee{}} = Accounts.delete_attendee(attendee)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_attendee!(attendee.id) end
    end

    test "change_attendee/1 returns a attendee changeset" do
      attendee = attendee_fixture()
      assert %Ecto.Changeset{} = Accounts.change_attendee(attendee)
    end
  end
end
