defmodule SafiraWeb.AttendeeControllerTest do
  use SafiraWeb.ConnCase

  alias Safira.Accounts
  alias Safira.Accounts.Attendee

  @create_attrs %{nickname: "some nickname", uuid: "some uuid"}
  @update_attrs %{nickname: "some updated nickname", uuid: "some updated uuid"}
  @invalid_attrs %{nickname: nil, uuid: nil}

  def fixture(:attendee) do
    {:ok, attendee} = Accounts.create_attendee(@create_attrs)
    attendee
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all attendees", %{conn: conn} do
      conn = get conn, attendee_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create attendee" do
    test "renders attendee when data is valid", %{conn: conn} do
      conn = post conn, attendee_path(conn, :create), attendee: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, attendee_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "nickname" => "some nickname",
        "uuid" => "some uuid"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, attendee_path(conn, :create), attendee: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update attendee" do
    setup [:create_attendee]

    test "renders attendee when data is valid", %{conn: conn, attendee: %Attendee{id: id} = attendee} do
      conn = put conn, attendee_path(conn, :update, attendee), attendee: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, attendee_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "nickname" => "some updated nickname",
        "uuid" => "some updated uuid"}
    end

    test "renders errors when data is invalid", %{conn: conn, attendee: attendee} do
      conn = put conn, attendee_path(conn, :update, attendee), attendee: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete attendee" do
    setup [:create_attendee]

    test "deletes chosen attendee", %{conn: conn, attendee: attendee} do
      conn = delete conn, attendee_path(conn, :delete, attendee)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, attendee_path(conn, :show, attendee)
      end
    end
  end

  defp create_attendee(_) do
    attendee = fixture(:attendee)
    {:ok, attendee: attendee}
  end
end
