defmodule SafiraWeb.BuyControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "with valid token" do
      user = create_user_strategy(:user)
      attendee = insert(:attendee, user: user)

      redeemable = insert(:redeemable)
      attrs = %{"redeemable" => %{"redeemable_id" => redeemable.id}}

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.buy_path(conn, :create, attrs))
        |> doc()

      assert json_response(conn, 200)["data"] == %{
               "Redeemable" => "#{redeemable.name} bought successfully!"
             }
    end
  end
end
