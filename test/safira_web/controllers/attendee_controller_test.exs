defmodule SafiraWeb.AttendeeControllerTest do
  alias Safira.Admin.Accounts
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    attendee = insert(:attendee, user: user)

    attrs = %{"id" => attendee.id, "attendee" => %{"nickname" => "john_doe123"}}

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     user: user,
     attendee: attendee,
     attrs: attrs}
  end

  describe "delete attendee" do
    test "with valid token", %{user: user, attendee: attendee} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))

      assert json_response(conn, 204) == ""

      assert_error_sent 404, fn ->
        get(conn, Routes.attendee_path(conn, :show, attendee.id))
      end
    end

    test "with valid token and with badges", %{user: user, attendee: attendee} do
      badge = insert(:badge)
      insert(:redeem, attendee: attendee, badge: badge)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))

      assert json_response(conn, 204) == ""

      assert_error_sent 404, fn ->
        get(conn, Routes.attendee_path(conn, :show, attendee.id))
      end
    end

    test "with invalid token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "different than the one who is making the operation" do
      [user1, user2] = insert_pair(:user)
      _attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)

      %{conn: conn, user: _user} = api_authenticate(user1)

      conn =
        conn
        |> delete(Routes.attendee_path(conn, :delete, attendee2.id))

      assert json_response(conn, 401)["error"] == "You have no permission to do this"
    end
  end

  describe "index" do
    test "with valid token", %{user: user, attendee: attendee} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.attendee_path(conn, :index))

      expected_response = [
        %{
          "avatar" => "/images/attendee-missing.png",
          "entries" => 0,
          "id" => attendee.id,
          "name" => attendee.name,
          "nickname" => attendee.nickname,
          "token_balance" => 0,
          "badges" => [],
          "badge_count" => 0
        }
      ]

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.attendee_path(conn, :index))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn} do
      conn =
        conn
        |> get(Routes.attendee_path(conn, :index))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "show" do
    test "with valid token", %{user: user, attendee: attendee} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.attendee_path(conn, :show, attendee.id))

      expected_attendee = %{
        "avatar" => "/images/attendee-missing.png",
        "entries" => 0,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => attendee.nickname,
        "token_balance" => 0,
        "badges" => [],
        "badge_count" => 0,
        "prizes" => [],
        "redeemables" => []
      }

      assert json_response(conn, 200)["data"] == expected_attendee
    end

    test "with invalid token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> get(Routes.attendee_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, attendee: attendee} do
      conn =
        conn
        |> get(Routes.attendee_path(conn, :show, attendee.id))

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "update attendee" do
    test "with valid token", %{user: user, attendee: attendee, attrs: attrs} do
      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      expected_attendee = %{
        "avatar" => "/images/attendee-missing.png",
        "entries" => 0,
        "id" => attendee.id,
        "name" => attendee.name,
        "nickname" => "john_doe123",
        "token_balance" => 0
      }

      assert json_response(conn, 200)["data"] == expected_attendee
    end

    test "with invalid token", %{conn: conn, attendee: attendee, attrs: attrs} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{"invalid"}")
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      assert json_response(conn, 401)["error"] == "invalid_token"
    end

    test "with no token", %{conn: conn, attendee: attendee, attrs: attrs} do
      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "different than the one who is making the operation", %{attrs: attrs} do
      [user1, user2] = insert_pair(:user)
      _attendee1 = insert(:attendee, user: user1)
      attendee2 = insert(:attendee, user: user2)

      %{conn: conn, user: _user} = api_authenticate(user1)

      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee2.id), attrs)

      assert json_response(conn, 401)["error"] == "Login error"
    end
  end

  describe "add_cv/1" do
    test "valid_cv", %{user: user, attendee: attendee, attrs: attrs} do
      cv = %Plug.Upload{
        filename: "ValidCV.pdf",
        path: "priv/fake/ValidCV.pdf",
        content_type: "application/pdf"
      }

      attendee_attrs = Map.get(attrs, "attendee") |> Map.put("cv", cv)
      attrs = Map.put(attrs, "attendee", attendee_attrs)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      updated_attendee = Accounts.get_attendee!(attendee.id)

      assert updated_attendee.cv != nil and updated_attendee.cv.file_name == "ValidCV.pdf"
    end

    test "invalid_cv_ext", %{user: user, attendee: attendee, attrs: attrs} do
      cv = %Plug.Upload{
        filename: "InvalidCVExt.txt",
        path: "priv/fake/InvalidCVExt.txt",
        content_type: "application/txt"
      }

      attendee_attrs = Map.get(attrs, "attendee") |> Map.put("cv", cv)
      attrs = Map.put(attrs, "attendee", attendee_attrs)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      updated_attendee = Accounts.get_attendee!(attendee.id)

      assert updated_attendee.cv == nil
    end

    test "invalid_cv_size", %{user: user, attendee: attendee, attrs: attrs} do
      cv = %Plug.Upload{
        filename: "InvalidCVSize.pdf",
        path: "priv/fake/InvalidCVSize.pdf",
        content_type: "application/pdf"
      }

      attendee_attrs = Map.get(attrs, "attendee") |> Map.put("cv", cv)
      attrs = Map.put(attrs, "attendee", attendee_attrs)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> put(Routes.attendee_path(conn, :update, attendee.id), attrs)

      updated_attendee = Accounts.get_attendee!(attendee.id)

      assert updated_attendee.cv == nil
    end
  end
end
