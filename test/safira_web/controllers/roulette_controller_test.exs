defmodule SafiraWeb.RouletteControllerTest do
  use SafiraWeb.ConnCase

  describe "spin" do
    test "with valid token (attendee with enough tokens)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user, token_balance: 1000)
      prize = create_prize_strategy(:prize, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.roulette_path(conn, :spin))
        |> doc()

      assert json_response(conn, 200)["prize"] == %{
               "avatar" => nil,
               "id" => prize.id,
               "name" => prize.name
             }
    end

    test "with valid token (attendee without enough tokens)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user, token_balance: 0)
      create_prize_strategy(:prize, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.roulette_path(conn, :spin))

      assert json_response(conn, 401) == %{
               "error" => "Insufficient token balance"
             }
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user, token_balance: 1000)
      create_prize_strategy(:prize, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> post(Routes.roulette_path(conn, :spin))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)
      create_prize_strategy(:prize, probability: 1.0)

      conn =
        conn
        |> post(Routes.roulette_path(conn, :spin))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "when user is not an attendee" do
      user = create_user_strategy(:user)
      insert(:staff, user: user)
      create_prize_strategy(:prize, probability: 1.0)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.roulette_path(conn, :spin))

      assert json_response(conn, 401)["error"] == "Only attendees can spin the wheel"
    end
  end

  describe "latest wins" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user, token_balance: 1000)
      prize = create_prize_strategy(:prize, probability: 1.0)
      attendee_prize = insert(:attendee_prize, attendee: attendee, prize: prize)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.roulette_path(conn, :latest_wins))
        |> doc()

      assert json_response(conn, 200)["data"] == [
               %{
                 "attendee_name" => attendee.name,
                 "attendee_nickname" => attendee.nickname,
                 "date" =>
                   String.replace(NaiveDateTime.to_string(attendee_prize.updated_at), " ", "T"),
                 "prize" => %{
                   "avatar" => nil,
                   "id" => prize.id,
                   "max_amount_per_attendee" => prize.max_amount_per_attendee,
                   "name" => prize.name,
                   "stock" => prize.stock
                 }
               }
             ]
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user, token_balance: 1000)
      prize = create_prize_strategy(:prize, probability: 1.0)
      insert(:attendee_prize, attendee: attendee, prize: prize)
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.roulette_path(conn, :latest_wins))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user, token_balance: 1000)
      prize = create_prize_strategy(:prize, probability: 1.0)
      insert(:attendee_prize, attendee: attendee, prize: prize)

      conn =
        conn
        |> get(Routes.roulette_path(conn, :latest_wins))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
