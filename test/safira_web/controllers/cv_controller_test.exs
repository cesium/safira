defmodule SafiraWeb.CVControllerTest do
  use SafiraWeb.ConnCase

  setup %{conn: conn} do
    badge = insert(:badge)

    user_company = create_user_strategy(:user)
    user_company_no_access = create_user_strategy(:user)

    company =
      insert(:company,
        user: user_company,
        badge: badge,
        has_cv_access: true,
        sponsorship: "Bronze"
      )

    company_no_access = insert(:company, user: user_company_no_access, has_cv_access: false)

    user_attendee_with_badge = create_user_strategy(:user)
    attendee_with_badge = insert(:attendee, user: user_attendee_with_badge)
    insert(:redeem, attendee: attendee_with_badge, badge: badge)

    user_attendee_without_badge = create_user_strategy(:user)
    attendee_without_badge = insert(:attendee, user: user_attendee_without_badge)

    cv = %Plug.Upload{
      filename: "ValidCV.pdf",
      path: "priv/fake/ValidCV.pdf",
      content_type: "application/pdf"
    }

    %{conn: conn1, user: _user} = api_authenticate(user_attendee_with_badge)

    conn1
    |> put(Routes.attendee_path(conn, :update, attendee_with_badge.id), %{
      "id" => attendee_with_badge.id,
      "attendee" => %{"cv" => cv}
    })

    %{conn: conn2, user: _user} = api_authenticate(user_attendee_without_badge)

    conn2
    |> put(Routes.attendee_path(conn, :update, attendee_without_badge.id), %{
      "id" => attendee_without_badge.id,
      "attendee" => %{"cv" => cv}
    })

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     user_company: user_company,
     company: company,
     attendee_with_badge: attendee_with_badge,
     user_company_no_access: user_company_no_access,
     company_no_access: company_no_access}
  end

  describe "company_cvs" do
    test "company downloads the CVs of it's own attendees", %{
      user_company: user_company,
      company: company,
      attendee_with_badge: attendee
    } do
      %{conn: conn, user: _user} = api_authenticate(user_company)

      conn =
        conn
        |> get(Routes.cv_path(conn, :company_cvs, company.id))

      assert response(conn, 200)

      assert {:ok, files} = :zip.extract(conn.resp_body, [:memory])

      assert Kernel.length(files) == 1

      assert List.first(files) |> Kernel.elem(0) ==
               (attendee.nickname <> ".pdf") |> String.to_charlist()
    end

    test "admin downloads the CVs of a company's attendees", %{
      company: company,
      attendee_with_badge: attendee
    } do
      user = create_user_strategy(:user)
      insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.cv_path(conn, :company_cvs, company.id))

      assert response(conn, 200)

      assert {:ok, files} = :zip.extract(conn.resp_body, [:memory])

      assert Kernel.length(files) == 1

      assert List.first(files) |> Kernel.elem(0) ==
               (attendee.nickname <> ".pdf") |> String.to_charlist()
    end

    test "company downloads the CVs of other company's attendees", %{
      user_company: user_company
    } do
      other_company = insert(:company)

      %{conn: conn, user: _user} = api_authenticate(user_company)

      conn =
        conn
        |> get(Routes.cv_path(conn, :company_cvs, other_company.id))

      assert response(conn, 403)
    end
  end
end
