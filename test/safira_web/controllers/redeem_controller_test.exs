defmodule SafiraWeb.RedeemControllerTest do
  use SafiraWeb.ConnCase

  describe "create" do
    test "with valid token (company)" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      insert(:company, user: user, badge: badge)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id
        }
      }

      conn =
        conn
        |> post(Routes.redeem_path(conn, :create), params)

      assert json_response(conn, 201)["redeem"] ==
               "Badge redeemed successfully. Tokens added to your balance"
    end

    test "with valid token (manager)" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "badge_id" => badge.id
        }
      }

      conn =
        conn
        |> post(Routes.redeem_path(conn, :create), params)

      assert json_response(conn, 201)["redeem"] ==
               "Badge redeemed successfully. Tokens added to your balance"
    end

    test "with valid token (attendee)" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "badge_id" => badge.id
        }
      }

      conn =
        conn
        |> post(Routes.redeem_path(conn, :create), params)

      assert json_response(conn, 401)["error"] ==
               "Cannot access resource"
    end

    test "with valid token (badge does not exist)" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "badge_id" => 42
        }
      }

      assert_error_sent 404, fn ->
        conn =
          conn
          |> post(Routes.redeem_path(conn, :create), params)
      end
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "badge_id" => badge.id
        }
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> post(Routes.redeem_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "badge_id" => badge.id
        }
      }

      conn =
        conn
        |> post(Routes.redeem_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "when user is not an attendee" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      prize = create_prize_strategy(:prize, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.roulette_path(conn, :spin))

      assert json_response(conn, 401)["error"] == "Only attendees can spin the wheel"
    end
  end
end
