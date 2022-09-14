defmodule SafiraWeb.SpotlightControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "create a spotlight" do
      attendee_user = create_user_strategy(:user)
      attendee = insert(:attendee, user: attendee_user)
      %{conn: conn, user: _} = api_authenticate(attendee_user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create))
        |> doc()

      assert json_response(conn, 201)["spotlight"] == "Spotlight requested succesfully"
    end

    test "returns error when spotlight is not available" do
        attendee_user = create_user_strategy(:user)
        attendee = insert(:attendee, user: attendee_user)
        %{conn: conn, user: _} = api_authenticate(attendee_user)

        conn =
          conn
          |> post(Routes.spotlight_path(conn, :create))
          |> doc()

        assert json_response(conn, 401)["error"] == "Cannot access resource"
    end
  end
end
