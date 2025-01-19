defmodule SafiraWeb.UserConfirmationLiveTest do
  use SafiraWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Safira.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm/some-token")
      assert html =~ "Email address has been verified!"
    end
  end
end
