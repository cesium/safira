defmodule SafiraWeb.AttendeeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @attendee_nickname "john_doe123"

  describe "delete attendee" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      %{conn: conn, user: _} = api_authenticate(user)
      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 204) == ""

      assert_error_sent 404, fn ->
        get(conn, Routes.attendee_path(conn, :show, attendee.id))
      end
    end

    test "with valid token and with badges" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      badge = insert(:badge)
      insert(:redeem, attendee: attendee, badge: badge)
      %{conn: conn, user: _} = api_authenticate(user)
      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 204) == ""

      assert_error_sent 404, fn ->
        get(conn, Routes.attendee_path(conn, :show, attendee.id))
      end
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      conn = conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      attendee = insert(:attendee)
      conn = conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "different than the one who is making the operation" do
      user1 = insert(:user)
      user2 = insert(:user)
      _attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)
      %{conn: conn, user: _} = api_authenticate(user1)
      conn = conn
        |> delete(Routes.attendee_path(conn, :delete, attendee2.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "You have no permission to do this"
    end
  end

  describe "index" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      %{conn: conn, user: _} = api_authenticate(user)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)["data"] == [%{
        "avatar" => "/images/attendee-missing.png",
        "entries" => 0,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => attendee.nickname,
        "token_balance" => 0,
        "badges" => [],
        "badge_count" => 0,
        "volunteer" => attendee.volunteer
      }]
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :index))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token", %{conn: conn} do
      attendee = insert(:attendee)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :index))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      %{conn: conn, user: _} = api_authenticate(user)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :show, attendee.id))
        |> doc()

      assert json_response(conn, 200)["data"] == %{
        "avatar" => "/images/attendee-missing.png",
        "entries" => 0,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => attendee.nickname,
        "token_balance" => 0,
        "badges" => [],
        "badge_count" => 0,
        "volunteer" => attendee.volunteer,
        "prizes" => [],
        "redeemables" => []
      }
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :show, attendee.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token", %{conn: conn} do
      attendee = insert(:attendee)
      conn =
        conn
        |> get(Routes.attendee_path(conn, :show, attendee.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "update attendee" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      %{conn: conn, user: _} = api_authenticate(user)
      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id),
          %{"id" => attendee.id, "attendee" => %{"nickname" => @attendee_nickname}})
        |> doc()

      assert json_response(conn, 200)["data"] == %{
        "avatar" => "/images/attendee-missing.png",
        "entries" => 0,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => @attendee_nickname,
        "token_balance" => 0
      }
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)
      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id),
          %{"id" => attendee.id, "attendee" => %{"nickname" => @attendee_nickname}})
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token", %{conn: conn} do
      attendee = insert(:attendee)
      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id),
          %{"id" => attendee.id, "attendee" => %{"nickname" => @attendee_nickname}})
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "different than the one who is making the operation" do
      user1 = insert(:user)
      user2 = insert(:user)
      _attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)
      %{conn: conn, user: _} = api_authenticate(user1)
      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee2.id),
          %{"id" => attendee2.id, "attendee" => %{"nickname" => @attendee_nickname}})
        |> doc()
      assert json_response(conn, 401)["error"] == "Login error"
    end
  end
end
