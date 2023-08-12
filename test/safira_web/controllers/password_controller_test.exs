defmodule SafiraWeb.PasswordControllerTest do
  use SafiraWeb.ConnCase
  use Bamboo.Test
  use Timex

  alias Safira.Accounts.User

  alias Safira.Auth
  alias Safira.Email

  alias Safira.Repo

  setup %{conn: conn} do
    user = create_user_strategy(:user)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "create" do
    test "password reset with valid user", %{conn: conn, user: user} do
      attrs = %{"user" => %{"email" => user.email}}

      conn =
        conn
        |> post(Routes.password_path(conn, :create), attrs)

      assert json_response(conn, 201)["data"]["attributes"] != %{}
      # TODO: Use assert_delivered_email
      assert {:ok, _email = %Bamboo.Email{}} =
               Email.send_reset_email(user.email, user.reset_password_token)
    end

    test "password reset with invalid user", %{conn: conn} do
      user = build(:user)
      attrs = %{"user" => %{"email" => user.email}}

      conn =
        conn
        |> post(Routes.password_path(conn, :create), attrs)

      assert json_response(conn, 201)["data"]["attributes"] != %{}
    end
  end

  describe "update" do
    test "user password with valid token", %{conn: conn, user: user} do
      user = Auth.reset_password_token(user)
      attrs = %{"user" => %{"password" => user.password}}

      conn =
        conn
        |> put(Routes.password_path(conn, :update, user.reset_password_token), attrs)

      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "user password with nonexistent token", %{conn: conn, user: user} do
      user = Auth.reset_password_token(user)
      attrs = %{"user" => %{"password" => user.password}}

      conn =
        conn
        |> put(Routes.password_path(conn, :update, Auth.random_string(42)), attrs)

      assert json_response(conn, 400)["errors"] == [
               %{"detail" => "Password reset token nonexistent."}
             ]
    end

    test "user password with expired token", %{conn: conn, user: user} do
      user = reset_password_token(user)
      attrs = %{"user" => %{"password" => user.password}}

      conn =
        conn
        |> put(Routes.password_path(conn, :update, user.reset_password_token), attrs)

      assert json_response(conn, 400)["errors"] == [
               %{"detail" => "Password reset token expired."}
             ]
    end
  end

  defp reset_password_token(user) do
    token = Auth.random_string(48)
    sent_at = Timex.shift(DateTime.utc_now(), days: -10)

    user
    |> User.password_token_changeset(%{reset_password_token: token, reset_token_sent_at: sent_at})
    |> Repo.update!()
  end
end
