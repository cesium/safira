defmodule SafiraWeb.BadgeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    badge = insert(:badge)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, badge: badge}
  end

  describe "index" do
    test "with valid token", %{user: user, badge: badge} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.badge_path(conn, :index))

      expected_response = [
        %{
          "avatar" => "/images/badge-missing.png",
          "begin" => DateTime.to_iso8601(badge.begin),
          "description" => badge.description,
          "end" => DateTime.to_iso8601(badge.end),
          "id" => badge.id,
          "name" => badge.name,
          "tokens" => badge.tokens,
          "type" => badge.type
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.badge_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      conn =
        conn
        |> get(Routes.badge_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token", %{user: user, badge: badge} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.badge_path(conn, :show, badge.id))

      expected_bage = %{
        "avatar" => "/images/badge-missing.png",
        "begin" => DateTime.to_iso8601(badge.begin),
        "description" => badge.description,
        "end" => DateTime.to_iso8601(badge.end),
        "id" => badge.id,
        "name" => badge.name,
        "tokens" => badge.tokens,
        "type" => badge.type,
        "attendees" => []
      }

      assert json_response(conn, 200)["data"] == expected_bage
    end

    test "with invalid token", %{conn: conn, badge: badge} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.badge_path(conn, :show, badge.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, badge: badge} do
      conn =
        conn
        |> get(Routes.badge_path(conn, :show, badge.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
