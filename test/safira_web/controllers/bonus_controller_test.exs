defmodule SafiraWeb.BonusControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    attendee_user = create_user_strategy(:user)
    company_user = create_user_strategy(:user)

    attendee = insert(:attendee, user: attendee_user)
    company = insert(:company, user: company_user)

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     attendee: attendee,
     company: company}
  end

  describe "give bonus" do
    test "with valid token", %{attendee: attendee, company: company} do
      %{conn: conn, user: _user} = api_authenticate(company.user)

      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))

      expected_bonus = %{
        "name" => attendee.name,
        "attendee_id" => attendee.id,
        "token_bonus" => Application.fetch_env!(:safira, :token_bonus),
        "bonus_count" => 1,
        "company_id" => company.id
      }

      assert json_response(conn, 200) == expected_bonus
    end

    test "with invalid token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "being an attendee user", %{conn: conn, attendee: attendee} do
      %{conn: conn, user: _user} = api_authenticate(attendee.user)

      conn =
        conn
        |> post(Routes.bonus_path(conn, :give_bonus, attendee.id))

      assert json_response(conn, 401)["error"] == "Cannot access resource"
    end
  end
end
