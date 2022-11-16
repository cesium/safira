defmodule SafiraWeb.LeaderboardControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "attendee1 has more badges than attendee2" do
      user1 = create_user_strategy(:user)
      user2 = create_user_strategy(:user)
      attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)

      %{conn: conn, user: _user} = api_authenticate(user1)

      [badge1, badge2, badge3] = insert_list(3, :badge)
      insert(:redeem, attendee: attendee1, badge: badge1)
      insert(:redeem, attendee: attendee1, badge: badge2)
      insert(:redeem, attendee: attendee2, badge: badge3)

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :index))

      expected_response = [
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 2,
          "id" => attendee1.id,
          "name" => attendee1.name,
          "nickname" => attendee1.nickname,
          "token_balance" => attendee1.token_balance
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => attendee2.token_balance
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "same badges, but attendee1 has more token_balance" do
      user1 = create_user_strategy(:user)
      user2 = create_user_strategy(:user)
      attendee1 = insert(:attendee, user: user1, token_balance: 20)
      attendee2 = insert(:attendee, user: user2, token_balance: 10)

      %{conn: conn, user: _user} = api_authenticate(user1)

      [badge1, badge2] = insert_list(2, :badge)
      insert(:redeem, attendee: attendee1, badge: badge1)
      insert(:redeem, attendee: attendee2, badge: badge2)

      expected_response = [
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee1.id,
          "name" => attendee1.name,
          "nickname" => attendee1.nickname,
          "token_balance" => attendee1.token_balance
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => attendee2.token_balance
        }
      ]

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :index))

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token" do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.leaderboard_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token" do
      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "daily" do
    test "attendee1 has more badges than attendee2" do
      user1 = create_user_strategy(:user)
      user2 = create_user_strategy(:user)
      attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)

      %{conn: conn, user: _user} = api_authenticate(user1)

      [badge1, badge2, badge3] = insert_list(3, :badge)
      insert(:redeem, attendee: attendee1, badge: badge1)
      insert(:redeem, attendee: attendee1, badge: badge2)
      insert(:redeem, attendee: attendee2, badge: badge3)
      insert(:daily_token, attendee: attendee1)
      insert(:daily_token, attendee: attendee2)

      date = Date.utc_today() |> to_string()

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :daily, date))

      expected_response = [
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 2,
          "id" => attendee1.id,
          "name" => attendee1.name,
          "nickname" => attendee1.nickname,
          "token_balance" => 10
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => 10
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "same badges, but attendee1 has more daily_tokens" do
      user1 = create_user_strategy(:user)
      user2 = create_user_strategy(:user)
      attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)

      %{conn: conn, user: _user} = api_authenticate(user1)

      [badge1, badge2, badge3] = insert_list(3, :badge)
      insert(:redeem, attendee: attendee1, badge: badge1)
      insert(:redeem, attendee: attendee1, badge: badge2)
      insert(:redeem, attendee: attendee2, badge: badge3)
      insert(:daily_token, attendee: attendee1, quantity: 20)
      insert(:daily_token, attendee: attendee2)

      date = Date.utc_today() |> to_string()

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :daily, date))

      expected_response = [
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 2,
          "id" => attendee1.id,
          "name" => attendee1.name,
          "nickname" => attendee1.nickname,
          "token_balance" => 20
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => 10
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "right format, but invalid date" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      # month: 17
      date = "2021-17-03"

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :daily, date))

      assert json_response(conn, 400)["error"] == "Date should be in {YYYY}-{MM}-{DD} format"
    end

    test "wrong date format" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      date = "December 3, 2022"

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :daily, date))

      assert json_response(conn, 400)["error"] == "Date should be in {YYYY}-{MM}-{DD} format"
    end
  end
end
