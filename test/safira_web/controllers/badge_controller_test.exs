defmodule SafiraWeb.BadgeControllerTest do
  use SafiraWeb.ConnCase

  alias Safira.Contest
  alias Safira.Contest.Badge

  @create_attrs %{begin: "2010-04-17 14:00:00.000000Z", end: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{begin: "2011-05-18 15:01:01.000000Z", end: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{begin: nil, end: nil}

  def fixture(:badge) do
    {:ok, badge} = Contest.create_badge(@create_attrs)
    badge
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all badges", %{conn: conn} do
      conn = get conn, badge_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create badge" do
    test "renders badge when data is valid", %{conn: conn} do
      conn = post conn, badge_path(conn, :create), badge: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, badge_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "begin" => "2010-04-17 14:00:00.000000Z",
        "end" => "2010-04-17 14:00:00.000000Z"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, badge_path(conn, :create), badge: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update badge" do
    setup [:create_badge]

    test "renders badge when data is valid", %{conn: conn, badge: %Badge{id: id} = badge} do
      conn = put conn, badge_path(conn, :update, badge), badge: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, badge_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "begin" => "2011-05-18 15:01:01.000000Z",
        "end" => "2011-05-18 15:01:01.000000Z"}
    end

    test "renders errors when data is invalid", %{conn: conn, badge: badge} do
      conn = put conn, badge_path(conn, :update, badge), badge: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete badge" do
    setup [:create_badge]

    test "deletes chosen badge", %{conn: conn, badge: badge} do
      conn = delete conn, badge_path(conn, :delete, badge)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, badge_path(conn, :show, badge)
      end
    end
  end

  defp create_badge(_) do
    badge = fixture(:badge)
    {:ok, badge: badge}
  end
end
