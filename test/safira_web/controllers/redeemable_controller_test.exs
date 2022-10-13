defmodule SafiraWeb.RedeemableControllerTest do
  use SafiraWeb.ConnCase

  describe "index" do
    test "with valid token (attendee)" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "can_buy" => redeemable.max_per_user,
                 "description" => redeemable.description,
                 "id" => redeemable.id,
                 "image" => "/images/redeemable-missing.png",
                 "max_per_user" => redeemable.max_per_user,
                 "name" => redeemable.name,
                 "price" => redeemable.price,
                 "stock" => redeemable.stock
               }
             ]
    end

    test "with valid token (not attendee)" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:manager, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "can_buy" => 0,
                 "description" => redeemable.description,
                 "id" => redeemable.id,
                 "image" => "/images/redeemable-missing.png",
                 "max_per_user" => redeemable.max_per_user,
                 "name" => redeemable.name,
                 "price" => redeemable.price,
                 "stock" => redeemable.stock
               }
             ]
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.redeemable_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token (attendee)" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :show, redeemable.id))

      assert json_response(conn, 200)["data"] == %{
               "can_buy" => redeemable.max_per_user,
               "description" => redeemable.description,
               "id" => redeemable.id,
               "image" => "/images/redeemable-missing.png",
               "max_per_user" => redeemable.max_per_user,
               "name" => redeemable.name,
               "price" => redeemable.price,
               "stock" => redeemable.stock
             }
    end

    test "with valid token (not attendee)" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:manager, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :show, redeemable.id))

      assert json_response(conn, 200)["data"] == %{
               "can_buy" => 0,
               "description" => redeemable.description,
               "id" => redeemable.id,
               "image" => "/images/redeemable-missing.png",
               "max_per_user" => redeemable.max_per_user,
               "name" => redeemable.name,
               "price" => redeemable.price,
               "stock" => redeemable.stock
             }
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.redeemable_path(conn, :show, redeemable.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token" do
      user = create_user_strategy(:user)
      redeemable = insert(:redeemable)
      insert(:attendee, user: user)

      conn =
        conn
        |> get(Routes.redeemable_path(conn, :show, redeemable.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
