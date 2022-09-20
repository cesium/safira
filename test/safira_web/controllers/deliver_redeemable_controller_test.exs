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
  end
end
