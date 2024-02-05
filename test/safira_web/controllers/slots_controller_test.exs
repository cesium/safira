defmodule SafiraWeb.SlotsControllerTest do
  use SafiraWeb.ConnCase

  describe "spin" do
    test "with valid bet (attendee with enough tokens)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user, token_balance: 1000)
      bet = Enum.random(1..100)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.slots_path(conn, :spin, bet: bet))
        |> doc()

      assert json_response(conn, 200)
    end

    test "with valid bet (attendee without enough tokens)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user, token_balance: 0)
      create_payout_strategy(:payout, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.slots_path(conn, :spin, bet: 100))

      assert json_response(conn, 401) == %{
               "error" => "Insufficient token balance"
             }
    end

    test "with invalid bet (float value)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)
      create_payout_strategy(:payout, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.slots_path(conn, :spin, bet: 1.2))

      assert json_response(conn, 400) == %{
               "error" => "Bet should be an integer"
             }
    end

    test "with invalid bet (negative value)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)
      create_payout_strategy(:payout, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.slots_path(conn, :spin, bet: -1))

      assert json_response(conn, 400) == %{
               "error" => "Bet should be a positive integer"
             }
    end

    test "when user is not an attendee" do
      user = create_user_strategy(:user)
      insert(:staff, user: user)
      create_payout_strategy(:payout, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.slots_path(conn, :spin, bet: 100))

      assert json_response(conn, 401)["error"] == "Only attendees can play the slots"
    end
  end
end
