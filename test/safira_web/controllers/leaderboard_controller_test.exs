defmodule SafiraWeb.LeaderboardControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "one attendee with more badges" do
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
          "token_balance" => attendee1.token_balance,
          "volunteer" => attendee1.volunteer
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => attendee2.token_balance,
          "volunteer" => attendee2.volunteer
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "same badges, but different token_balance" do
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
          "token_balance" => attendee1.token_balance,
          "volunteer" => attendee1.volunteer
        },
        %{
          "avatar" => "/images/attendee-missing.png",
          "badges" => 1,
          "id" => attendee2.id,
          "name" => attendee2.name,
          "nickname" => attendee2.nickname,
          "token_balance" => attendee2.token_balance,
          "volunteer" => attendee2.volunteer
        }
      ]

      conn =
        conn
        |> get(Routes.leaderboard_path(conn, :index))

      assert json_response(conn, 200)["data"] == expected_response
    end
  end
end
