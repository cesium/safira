defmodule SafiraWeb.BuyControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    redeemable = insert(:redeemable, stock: Enum.random(1..10))
    attendee = insert(:attendee, token_balance: redeemable.price, user: user)

    attrs = %{"redeemable" => %{"redeemable_id" => redeemable.id}}

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     user: user,
     attrs: attrs,
     redeemable: redeemable}
  end

  describe "create" do
    test "with valid token", %{conn: conn, user: user, attrs: attrs, redeemable: redeemable} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 200) == %{
               "Redeemable" => "#{redeemable.name} bought successfully!"
             }
    end

    test "with invalid token", %{conn: conn, attrs: attrs} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, attrs: attrs} do
      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "when user is not an attendee", %{attrs: attrs, redeemable: redeemable} do
      user = create_user_strategy(:user)
      %{conn: conn, user: _user} = api_authenticate(user)
      company = insert(:company, user: user)

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 401)["error"] == "Only attendees can buy products!"
    end

    test "when user doesn't have enough balance", %{attrs: attrs, redeemable: redeemable} do
      user = create_user_strategy(:user)
      %{conn: conn, user: _user} = api_authenticate(user)
      attendee = insert(:attendee, token_balance: redeemable.price - 1, user: user)

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 422)["errors"]["token_balance"] == [
               "Token balance is insufficient."
             ]
    end

    test "when redeemable is out of stock", %{conn: conn, user: user} do
      %{conn: conn, user: _user} = api_authenticate(user)
      redeemable = insert(:redeemable, stock: 0)

      attrs = %{"redeemable" => %{"redeemable_id" => redeemable.id}}

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 422)["errors"]["stock"] == ["Item is sold out!"]
    end

    test "with no redeemable_id param", %{conn: conn, user: user, redeemable: redeemable} do
      %{conn: conn, user: _user} = api_authenticate(user)

      attrs = %{"redeemable" => %{"name" => redeemable.name}}

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 400)["Redeemable"] == "No 'redeemable_id' param"
    end
  end
end
