defmodule SafiraWeb.BonusControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "give bonus" do
    test "with valid token" do
      company_user = create_user_strategy(:user)
      attendee_user = create_user_strategy(:user)

      company = insert(:company, user: company_user)
      attendee = insert(:attendee, user: attendee_user)

      %{conn: conn, user: _} = api_authenticate(company_user)

      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))
        |> doc()

      assert json_response(conn, 200) == %{
        "name" => attendee.name,
        "attendee_id" => attendee.id,
        "token_bonus" => Application.fetch_env!(:safira, :token_bonus),
        "bonus_count" => 1,
        "company_id" => company.id
      }
    end

    test "with invalid token" do
      company_user = create_user_strategy(:user)
      attendee_user = create_user_strategy(:user)

      company = insert(:company, user: company_user)
      attendee = insert(:attendee, user: attendee_user)

      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token" do
      attendee_user = create_user_strategy(:user)
      attendee = insert(:attendee, user: attendee_user)

      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
