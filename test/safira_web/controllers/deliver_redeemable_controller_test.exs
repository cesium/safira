defmodule SafiraWeb.DeliverRedeemableControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "with valid token (manager)" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 200) == %{
               "Redeemable" => "#{redeemable.name} redeemed successfully!"
             }
    end

    test "with valid token (not a manager)" do
      user = create_user_strategy(:user)
      insert(:attendee, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 401) == %{"error" => "Only managers can deliver redeemables"}
    end

    test "attendee does not exist" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      redeemable = insert(:redeemable)
      insert(:buy, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => Ecto.UUID.generate(),
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 404)["User"] == "Attendee does not exist"
    end

    test "redeemable does not exist" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      insert(:buy, attendee: attendee)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => "123",
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 404)["Redeemable"] == "There is no such redeemable"
    end

    test "without quantity param" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 400)["Redeemable"] == "Json does not have `quantity` param"
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.deliver_redeemable_path(conn, :show, attendee.id))

      expected_response = [
        %{
          "id" => redeemable.id,
          "image" => "/images/redeemable-missing.png",
          "name" => redeemable.name,
          "not_redeemed" => 1
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "show after redeem" do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)
      redeemable = insert(:redeemable)
      insert(:buy, attendee: attendee, redeemable: redeemable)

      %{conn: conn, user: _} = api_authenticate(user)

      params = %{
        "redeem" => %{
          "attendee_id" => attendee.id,
          "redeemable" => redeemable.id,
          "quantity" => 1
        }
      }

      conn =
        conn
        |> post(Routes.deliver_redeemable_path(conn, :create), params)
        |> get(Routes.deliver_redeemable_path(conn, :show, attendee.id))

      assert json_response(conn, 200)["data"] == []
    end

    test "with invalid token", %{conn: conn} do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.deliver_redeemable_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      user = create_user_strategy(:user)
      insert(:manager, user: user)
      attendee = insert(:attendee)

      conn =
        conn
        |> get(Routes.deliver_redeemable_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
