defmodule SafiraWeb.AuthControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "me" do
    test "attendee", %{user: user} do
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :attendee))

      expected_attendee = %{
        "avatar" => "/images/attendee-missing.png",
        "email" => user.email,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => attendee.nickname
      }

      assert json_response(conn, 200) == expected_attendee
    end

    test "company", %{user: user} do
      company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :company))

      expected_company = %{
        "badge_id" => nil,
        "email" => user.email,
        "id" => company.id,
        "name" => company.name,
        "sponsorship" => company.sponsorship
      }

      assert json_response(conn, 200) == expected_company
    end

    test "user", %{user: user} do
      company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :user))

      expected_user = %{
        "email" => user.email,
        "id" => user.id,
        "type" => "company"
      }

      assert json_response(conn, 200) == expected_user
    end
  end

  describe "sign_up" do
    test "user" do
      attendee = insert(:attendee, user: nil)
      user = build(:user)

      attrs = %{
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
        |> post(Routes.auth_path(conn, :sign_up), attrs)

      assert json_response(conn, 200)["jwt"] != ""
    end
  end

  describe "sign_in" do
    test "user with valid credentials", %{user: user} do
      attrs = %{"email" => user.email, "password" => user.password}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), attrs)

      assert json_response(conn, 200)["jwt"] != ""
    end

    test "user with invalid credentials (wrong password)", %{user: user} do
      struct = %{"email" => user.email, "password" => "test1234"}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), struct)

      assert json_response(conn, 401)["error"] == "Login error"
    end

    test "user with invalid credentials (non existing user)", %{user: user} do
      attrs = %{"email" => "wrong@email.pt", "password" => user.password}

      conn =
        conn
        |> post(Routes.auth_path(conn, :sign_in), attrs)

      assert json_response(conn, 401)["error"] == "Login error"
    end
  end

  describe "is_registered" do
    test "is registered", %{user: user} do
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :is_registered, attendee.id))

      assert json_response(conn, 200) == %{"is_registered" => true}
    end

    test "is not registered", %{user: user} do
      attendee = insert(:attendee, user: user)
      unregistered_attendee = insert(:attendee, user: nil)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.auth_path(conn, :is_registered, unregistered_attendee.id))

      assert json_response(conn, 200) == %{"is_registered" => false}
    end
  end
end
