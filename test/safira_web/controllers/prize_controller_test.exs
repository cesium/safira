defmodule SafiraWeb.PrizeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    prize = insert(:prize)
    attendee = insert(:attendee, user: user)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, prize: prize}
  end

  describe "index" do
    test "with valid token", %{conn: conn, user: user, prize: prize} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.prize_path(conn, :index))

      expected_response = [
        %{
          "id" => prize.id,
          "name" => prize.name,
          "avatar" => nil,
          "max_amount_per_attendee" => prize.max_amount_per_attendee,
          "stock" => prize.stock
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.prize_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      conn =
        conn
        |> get(Routes.prize_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token", %{conn: conn, user: user, prize: prize} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.prize_path(conn, :show, prize.id))

      expected_prize = %{
        "id" => prize.id,
        "name" => prize.name,
        "avatar" => nil,
        "max_amount_per_attendee" => prize.max_amount_per_attendee,
        "stock" => prize.stock
      }

      assert json_response(conn, 200)["data"] == expected_prize
    end

    test "with invalid token", %{conn: conn, prize: prize} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.prize_path(conn, :show, prize.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, prize: prize} do
      conn =
        conn
        |> get(Routes.prize_path(conn, :show, prize.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
