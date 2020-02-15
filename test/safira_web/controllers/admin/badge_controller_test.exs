defmodule SafiraWeb.Admin.BadgeControllerTest do
  use SafiraWeb.ConnCase

  alias Safira.Admin.Contest

  @create_attrs %{begin: "2010-04-17T14:00:00Z", description: "some description", end: "2010-04-17T14:00:00Z", name: "some name", type: 42}
  @update_attrs %{begin: "2011-05-18T15:01:01Z", description: "some updated description", end: "2011-05-18T15:01:01Z", name: "some updated name", type: 43}
  @invalid_attrs %{begin: nil, description: nil, end: nil, name: nil, type: nil}

  def fixture(:badge) do
    {:ok, badge} = Contest.create_badge(@create_attrs)
    badge
  end

  describe "index" do
    test "lists all badges", %{conn: conn} do
      conn = get conn, Routes.admin_badge_path(conn, :index)
      assert html_response(conn, 200) =~ "Badges"
    end
  end

  describe "new badge" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.admin_badge_path(conn, :new)
      assert html_response(conn, 200) =~ "New Badge"
    end
  end

  describe "create badge" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.admin_badge_path(conn, :create), badge: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :show, id)

      conn = get conn, Routes.admin_badge_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Badge Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.admin_badge_path(conn, :create), badge: @invalid_attrs
      assert html_response(conn, 200) =~ "New Badge"
    end
  end

  describe "edit badge" do
    setup [:create_badge]

    test "renders form for editing chosen badge", %{conn: conn, badge: badge} do
      conn = get conn, Routes.admin_badge_path(conn, :edit, badge)
      assert html_response(conn, 200) =~ "Edit Badge"
    end
  end

  describe "update badge" do
    setup [:create_badge]

    test "redirects when data is valid", %{conn: conn, badge: badge} do
      conn = put conn, Routes.admin_badge_path(conn, :update, badge), badge: @update_attrs
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :show, badge)

      conn = get conn, Routes.admin_badge_path(conn, :show, badge)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, badge: badge} do
      conn = put conn, Routes.admin_badge_path(conn, :update, badge), badge: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Badge"
    end
  end

  describe "delete badge" do
    setup [:create_badge]

    test "deletes chosen badge", %{conn: conn, badge: badge} do
      conn = delete conn, Routes.admin_badge_path(conn, :delete, badge)
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.admin_badge_path(conn, :show, badge)
      end
    end
  end

  defp create_badge(_) do
    badge = fixture(:badge)
    {:ok, badge: badge}
  end
end
