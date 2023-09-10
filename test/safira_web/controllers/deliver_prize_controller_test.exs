defmodule SafiraWeb.DeliverPrizeControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "with valid token (manager)" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)
      _attendee_prize = insert(:attendee_prize, attendee: attendee, prize: prize, redeemed: 0)
      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 200) == %{
               "Prize" => "#{prize.name} redeemed successfully!"
             }
    end

    test "with valid token (not a manager)" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _attendee1 = insert(:attendee, user: user)
      attendee = insert(:attendee)
      _attendee_prize = insert(:attendee_prize, attendee: attendee, prize: prize, redeemed: 0)
      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 401) == %{"error" => "Only managers can give prizes"}
    end

    test "with invalid token", %{conn: conn} do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)
      _attendee_prize = insert(:attendee_prize, attendee: attendee, prize: prize, redeemed: 0)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)
      _attendee_prize = insert(:attendee_prize, attendee: attendee, prize: prize, redeemed: 0)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "did not win the prize" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)
      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 400) == %{"Error" => "Wrong quantity"}
    end

    test "already redeemed the prize" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)

      insert(:attendee_prize, attendee: attendee, prize: prize, quantity: 1, redeemed: 1)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 400) == %{"Error" => "Wrong quantity"}
    end

    test "prize does not exist" do
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)
      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "prize" => 420,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 404) == %{"Redeemable" => "There is no such Prize"}
    end

    test "attendee does not exist" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => Ecto.UUID.generate(),
          "prize" => prize.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_prize_path(conn, :create), params)

      assert json_response(conn, 404) == %{"User" => "Attendee does not exist"}
    end
  end

  describe "show" do
    test "with valid token" do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)

      _attendee_prize =
        insert(:attendee_prize, attendee: attendee, prize: prize, quantity: 1, redeemed: 0)

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.deliver_prize_path(conn, :show, attendee.id))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => prize.id,
                 "image" => nil,
                 "name" => prize.name,
                 "not_redeemed" => 1
               }
             ]
    end

    test "with invalid token", %{conn: conn} do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)

      _attendee_prize =
        insert(:attendee_prize, attendee: attendee, prize: prize, quantity: 1, redeemed: 0)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.deliver_prize_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      prize = insert(:prize, is_redeemable: true)
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user)
      attendee = insert(:attendee)

      _attendee_prize =
        insert(:attendee_prize, attendee: attendee, prize: prize, quantity: 1, redeemed: 0)

      conn =
        conn
        |> get(Routes.deliver_prize_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "delete" do
    test "not a admin" do
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user, is_admin: false)
      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> delete(Routes.deliver_prize_path(conn, :delete, 0, 0))

      assert json_response(conn, 401)["error"] == "Only admins can remove prizes"
    end

    test "valid badge and attendee" do
      user = create_user_strategy(:user)
      _manager = insert(:manager, user: user, is_admin: true)
      badge = insert(:badge)

      attendee = insert(:attendee)
      insert(:redeem, attendee: attendee, badge: badge)

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> delete(Routes.deliver_prize_path(conn, :delete, badge.id, attendee.id))

      assert json_response(conn, 200) == %{"Badge" => "badge removed sucessfully from attendee"}
    end
  end
end
