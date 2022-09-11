defmodule SafiraWeb.BadgeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "with valid token"  do
      badge = insert(:badge)
      %{conn: conn, user: _} = api_authenticate(create_user_strategy(:user))
      conn = conn
        |> get(Routes.badge_path(conn, :index))
        |> doc()
      assert json_response(conn, 200)["data"] == [%{
        "avatar" => "/images/badge-missing.png",
        "begin" => badge.begin,
        "description" => badge.description,
        "end" => badge.end,
        "id" => badge.id,
        "name" => badge.name,
        "tokens" => badge.tokens,
        "type" => badge.type
      }]
    end

    test "with invalid token", %{conn: conn} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.badge_path(conn, :index))
        |> doc()
      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      conn = conn
        |> get(Routes.badge_path(conn, :index))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token"  do
      badge = insert(:badge)
      %{conn: conn, user: _} = api_authenticate(create_user_strategy(:user))
      conn = conn
        |> get(Routes.badge_path(conn, :show, badge.id))
        |> doc()
      assert json_response(conn, 200)["data"] == %{
        "avatar" => "/images/badge-missing.png",
        "begin" => badge.begin,
        "description" => badge.description,
        "end" => badge.end,
        "id" => badge.id,
        "name" => badge.name,
        "tokens" => badge.tokens,
        "type" => badge.type,
        "attendees" => []
      }
    end

    test "with invalid token", %{conn: conn} do
      badge = insert(:badge)
      conn = conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.badge_path(conn, :show, badge.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      badge = insert(:badge)
      conn = conn
        |> get(Routes.badge_path(conn, :show, badge.id))
        |> doc()
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
