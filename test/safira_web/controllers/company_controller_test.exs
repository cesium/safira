defmodule SafiraWeb.CompanyControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    badge = insert(:badge)
    company = insert(:company, user: user, badge: badge)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, company: company}
  end

  describe "index" do
    test "with valid token", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :index))

      expected_response = [
        %{
          "id" => company.id,
          "name" => company.name,
          "sponsorship" => company.sponsorship,
          "channel_id" => company.channel_id,
          "badge_id" => company.badge.id,
          "has_cv_access" => company.has_cv_access
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.company_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      conn =
        conn
        |> get(Routes.company_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))

      expected_company = %{
        "id" => company.id,
        "name" => company.name,
        "sponsorship" => company.sponsorship,
        "channel_id" => company.channel_id,
        "badge_id" => company.badge.id,
        "has_cv_access" => company.has_cv_access
      }

      assert json_response(conn, 200)["data"] == expected_company
    end

    test "with invalid token", %{conn: conn, company: company} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.company_path(conn, :show, company.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, company: company} do
      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "company_attendees" do
    test "company has not given any badge", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      assert json_response(conn, 200)["data"] == []
    end

    test "attendee redeemed the company's badge", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      attendee = insert(:attendee)
      insert(:redeem, attendee: attendee, badge: company.badge)

      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      expected_response = [
        %{
          "id" => attendee.id,
          "nickname" => attendee.nickname,
          "name" => attendee.name,
          "course" => attendee.course,
          "avatar" => nil,
          "cv" => nil,
          "token_balance" => attendee.token_balance,
          "entries" => attendee.entries
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "multiple attendees redeemed the company's badge", %{
      conn: _conn,
      user: user,
      company: company
    } do
      %{conn: conn, user: _user} = api_authenticate(user)

      [attendee1, attendee2] = insert_pair(:attendee)
      insert(:redeem, attendee: attendee1, badge: company.badge)
      insert(:redeem, attendee: attendee2, badge: company.badge)

      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      expected_response = [
        %{
          "id" => attendee1.id,
          "nickname" => attendee1.nickname,
          "name" => attendee1.name,
          "course" => attendee1.course,
          "avatar" => nil,
          "cv" => nil,
          "token_balance" => attendee1.token_balance,
          "entries" => attendee1.entries
        },
        %{
          "id" => attendee2.id,
          "nickname" => attendee2.nickname,
          "name" => attendee2.name,
          "course" => attendee2.course,
          "avatar" => nil,
          "cv" => nil,
          "token_balance" => attendee2.token_balance,
          "entries" => attendee2.entries
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "list attendees of other company", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      attendee = insert(:attendee)
      insert(:redeem, attendee: attendee)

      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      assert json_response(conn, 200)["data"] == []
    end

    test "one attendee reedem and one not", %{conn: _conn, user: user, company: company} do
      %{conn: conn, user: _user} = api_authenticate(user)

      attendee1 = insert(:attendee)
      attendee2 = insert(:attendee)
      insert(:redeem, attendee: attendee1, badge: company.badge)
      insert(:redeem, attendee: attendee2)

      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      expected_response = [
        %{
          "id" => attendee1.id,
          "nickname" => attendee1.nickname,
          "name" => attendee1.name,
          "course" => attendee1.course,
          "avatar" => nil,
          "cv" => nil,
          "token_balance" => attendee1.token_balance,
          "entries" => attendee1.entries
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token", %{conn: conn, company: company} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, company: company} do
      conn =
        conn
        |> get(Routes.company_path(conn, :company_attendees, company.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
