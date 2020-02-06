defmodule SafiraWeb.AttendeeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "delete attendee" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = build(:attendee) |> Map.put(:user_id, user.id) |> insert
      %{conn: conn, user: _} = api_authenticate(user)
      conn = conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 204) == ""
    end

    test "with valid token and with badges" do
      user = create_user_strategy(:user)
      attendee = build(:attendee) |> Map.put(:user_id, user.id) |> insert
      badge = insert(:badge)
      _redeem = build(:redeem)
        |> Map.put(:attendee_id, attendee.id)
        |> Map.put(:badge_id, badge.id)
        |> insert
      %{conn: conn, user: _} = api_authenticate(user)
      conn = conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))
        |> doc()
      assert json_response(conn, 204) == ""
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = build(:attendee) |> Map.put(:user_id, user.id) |> insert
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
      _attendee1 = build(:attendee) |> Map.put(:user_id, user1.id) |> insert
      attendee2 = build(:attendee) |> Map.put(:nickname, "testNick") |> Map.put(:user_id, user2.id) |> insert
      %{conn: conn, user: _} = api_authenticate(user1)
      conn = conn
        |> delete(Routes.attendee_path(conn, :delete, attendee2.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "You have no permission to do this"
    end
  end
end
