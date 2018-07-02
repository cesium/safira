defmodule SafiraWeb.RedeemControllerTest do
  use SafiraWeb.ConnCase

  alias Safira.Contest
  alias Safira.Contest.Redeem

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:redeem) do
    {:ok, redeem} = Contest.create_redeem(@create_attrs)
    redeem
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users_badges", %{conn: conn} do
      conn = get conn, redeem_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create redeem" do
    test "renders redeem when data is valid", %{conn: conn} do
      conn = post conn, redeem_path(conn, :create), redeem: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, redeem_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, redeem_path(conn, :create), redeem: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update redeem" do
    setup [:create_redeem]

    test "renders redeem when data is valid", %{conn: conn, redeem: %Redeem{id: id} = redeem} do
      conn = put conn, redeem_path(conn, :update, redeem), redeem: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, redeem_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn, redeem: redeem} do
      conn = put conn, redeem_path(conn, :update, redeem), redeem: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete redeem" do
    setup [:create_redeem]

    test "deletes chosen redeem", %{conn: conn, redeem: redeem} do
      conn = delete conn, redeem_path(conn, :delete, redeem)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, redeem_path(conn, :show, redeem)
      end
    end
  end

  defp create_redeem(_) do
    redeem = fixture(:redeem)
    {:ok, redeem: redeem}
  end
end
