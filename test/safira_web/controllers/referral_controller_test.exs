defmodule Safira.ReferralControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "redeems a referral" do
      referral_user = insert(:referral)
      attendee_user = create_user_strategy(:user)
      attendee = insert(:attendee, user: attendee_user)

      %{conn: conn, user: _user} = api_authenticate(attendee_user)

      conn =
        conn
        |> post(Routes.referral_path(conn, :create, %{"id" => referral_user.id}))

      assert json_response(conn, 201)["referral"] == "Referral redeemed successfully"
    end

    test "returns error when referral is not available" do
      referral_user = insert(:referral, available: false)
      attendee_user = create_user_strategy(:user)
      attendee = insert(:attendee, user: attendee_user)

      %{conn: conn, user: _user} = api_authenticate(attendee_user)

      conn =
        conn
        |> post(Routes.referral_path(conn, :create, %{"id" => referral_user.id}))

      assert json_response(conn, 401)["referral"] == "Referral not available"
    end
  end
end
