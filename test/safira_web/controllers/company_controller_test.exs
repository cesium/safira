defmodule SafiraWeb.CompanyControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    badge = insert(:badge)
    company = insert(:company, user: user, badge: badge)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, company: company}
  end

  describe "index" do
    test "with valid token", %{conn: conn, user: user, company: company} do
      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => company.id,
                 "name" => company.name,
                 "sponsorship" => company.sponsorship,
                 "channel_id" => company.channel_id,
                 "badge_id" => company.badge.id
               }
             ]
    end

    test "with invalid token" do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.company_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token" do
      conn =
        conn
        |> get(Routes.company_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token", %{conn: conn, user: user, company: company} do
      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))

      assert json_response(conn, 200)["data"] == %{
               "id" => company.id,
               "name" => company.name,
               "sponsorship" => company.sponsorship,
               "channel_id" => company.channel_id,
               "badge_id" => company.badge.id
             }
    end

    test "with invalid token", %{company: company} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.company_path(conn, :show, company.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{company: company} do
      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
