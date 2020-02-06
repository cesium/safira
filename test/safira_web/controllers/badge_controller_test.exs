defmodule SafiraWeb.BadgeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "badges" do
    test "with valid token"  do
      %{conn: conn, user: _} = api_authenticate(create_user_strategy(:user))
      conn = conn
        |> get(Routes.badge_path(conn, :index))
        |> doc()
      assert json_response(conn, 200)["data"] != %{}
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
end
