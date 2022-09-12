defmodule SafiraWeb.AuthControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "me" do
    test "attendee", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :attendee))
        |> doc()

      expected_attendee = %{
        "avatar" => "/images/attendee-missing.png",
        "email" => user.email,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => attendee.nickname
      }

      assert json_response(conn, 200) == expected_attendee
    end

    test "company", %{conn: conn} do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      company = insert(:company, user: user, badge: badge)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :company))
        |> doc()

      expected_company = %{
        "badge_id" => badge.id,
        "email" => user.email,
        "id" => company.id,
        "name" => company.name,
        "sponsorship" => company.sponsorship
      }

      assert json_response(conn, 200) == expected_company
    end

    test "user", %{conn: conn} do
      user = create_user_strategy(:user)
      company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :user))
        |> doc()

      expected_user = %{
        "email" => user.email,
        "id" => user.id,
        "type" => "company"
      }

      assert json_response(conn, 200) == expected_user
    end
  end

  describe "sign_up" do
    test "user", %{conn: conn} do
      attendee = insert(:attendee, user: nil)
      user = build(:user)

      struct = %{
        "user" => %{
          "email" => user.email,
          "password" => user.password,
          "password_confirmation" => user.password,
          "attendee" => %{
            "id" => attendee.id,
            "name" => attendee.name,
            "nickname" => attendee.nickname
          }
        }
      }

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_up), struct)
        |> doc()

      assert json_response(conn, 200)["jwt"] != %{}
    end
  end

  describe "sign_in" do
    test "user with valid credentials", %{conn: conn} do
      user = create_user_strategy(:user)
      struct = %{"email" => user.email, "password" => user.password}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), struct)
        |> doc()

      assert json_response(conn, 200)["jwt"] != %{}
    end

    test "user with invalid credentials (wrong password)", %{conn: conn} do
      user = create_user_strategy(:user)
      struct = %{"email" => user.email, "password" => "test1234"}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), struct)
        |> doc()

      assert json_response(conn, :unauthorized)["errors"] != %{}
    end

    test "user with invalid credentials (non existing user)", %{conn: conn} do
      user = create_user_strategy(:user)
      struct = %{"email" => "wrong@email.pt", "password" => user.password}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), struct)
        |> doc()

      assert json_response(conn, :unauthorized)["errors"] != %{}
    end
  end

  describe "is_registered" do
    test "is registered", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :is_registered, attendee.id))
        |> doc()

      assert json_response(conn, 200) == %{"is_registered" => true}
    end

    test "is not registered", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      unregistered_attendee = insert(:attendee, user: nil)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :is_registered, unregistered_attendee.id))
        |> doc()

      assert json_response(conn, 200) == %{"is_registered" => false}
    end
  end
end
