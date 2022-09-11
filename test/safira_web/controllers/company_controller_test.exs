defmodule SafiraWeb.CompanyControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "with valid token" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      company = insert(:company, user: user, badge: badge)

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)["data"] == [%{
        "id" => company.id,
        "name" => company.name,
        "sponsorship" => company.sponsorship,
        "channel_id" => company.channel_id,
        "badge_id" => badge.id
      }]
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      company = insert(:company, user: user, badge: badge)

      conn =
        conn
        |> get(Routes.company_path(conn, :index))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token" do
      company = insert(:company)

      conn =
        conn
        |> get(Routes.company_path(conn, :index))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      company = insert(:company, user: user, badge: badge)

      %{conn: conn, user: _} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))
        |> doc()

      assert json_response(conn, 200)["data"] == %{
        "id" => company.id,
        "name" => company.name,
        "sponsorship" => company.sponsorship,
        "channel_id" => company.channel_id,
        "badge_id" => badge.id
      }
    end

    test "with invalid token" do
      user = create_user_strategy(:user)
      badge = insert(:badge)
      company = insert(:company, user: user, badge: badge)

      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "with no token" do
      company = insert(:company)

      conn =
        conn
        |> get(Routes.company_path(conn, :show, company.id))
        |> doc()

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
