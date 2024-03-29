defmodule SafiraWeb.SpotlightControllerTest do
  @moduledoc """
  Tests for the SpotlightController.
  """
  use SafiraWeb.ConnCase

  alias Safira.Accounts.{Attendee, Company}
  alias Safira.Contest
  alias Safira.Interaction
  alias Safira.Interaction.Spotlight
  alias Safira.Repo

  setup %{conn: conn} do
    user = create_user_strategy(:user)
    company = insert(:company)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, company: company}
  end

  describe "index" do
    test "when user is an admin", %{user: user, company: company} do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "id" => company.id,
                   "name" => company.name,
                   "remaining" => company.remaining_spotlights
                 }
               ]
             }
    end

    test "when a spotlight for the given company is currently running", %{
      user: user,
      company: company
    } do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      # Start a spotlight for the company
      Interaction.start_spotlight(company)
      spotlight = Interaction.get_spotlight()
      assert spotlight != nil

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      # Get company again, since it was only in-memory
      company = Repo.get_by!(Company, id: company.id)

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "id" => company.id,
                   "name" => company.name,
                   "remaining" => company.remaining_spotlights,
                   "end" => DateTime.to_iso8601(spotlight.end)
                 }
               ]
             }
    end

    test "when there are two companies, but only one has a spotlight", %{
      user: user,
      company: company1
    } do
      _staff = insert(:staff, user: user, is_admin: true)
      company2 = insert(:company, remaining_spotlights: 1)

      %{conn: conn, user: _user} = api_authenticate(user)

      # Start a spotlight for the first company
      Interaction.start_spotlight(company1)
      spotlight = Interaction.get_spotlight()
      assert spotlight != nil

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      # Get company again, since it was only in-memory
      company1 = Repo.get_by!(Company, id: company1.id)
      company2 = Repo.get_by!(Company, id: company2.id)

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "id" => company2.id,
                   "name" => company2.name,
                   "remaining" => company2.remaining_spotlights
                 },
                 %{
                   "id" => company1.id,
                   "name" => company1.name,
                   "remaining" => company1.remaining_spotlights,
                   "end" => DateTime.to_iso8601(spotlight.end)
                 }
               ]
             }
    end

    test "when there are two companies, but none of them have a spotlight", %{
      user: user,
      company: company1
    } do
      _staff = insert(:staff, user: user, is_admin: true)
      company2 = insert(:company, remaining_spotlights: 1)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      # Get company again, since it was only in-memory
      company1 = Repo.get_by!(Company, id: company1.id)
      company2 = Repo.get_by!(Company, id: company2.id)

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "id" => company1.id,
                   "name" => company1.name,
                   "remaining" => company1.remaining_spotlights
                 },
                 %{
                   "id" => company2.id,
                   "name" => company2.name,
                   "remaining" => company2.remaining_spotlights
                 }
               ]
             }
    end

    test "when user is a staff", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: false)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when user is an attendee", %{user: user} do
      _attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when user is a company", %{user: user} do
      _company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end
  end

  describe "current" do
    test "when user is an admin", %{user: user, company: company} do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      # Start a spotlight for the company
      Interaction.start_spotlight(company)
      spotlight = Interaction.get_spotlight()
      assert spotlight != nil

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :current))

      # Get company again, since it was only in-memory
      company = Repo.get_by!(Company, id: company.id)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "id" => company.id,
                 "name" => company.name,
                 "badge_id" => company.badge_id,
                 "end" => DateTime.to_iso8601(spotlight.end)
               }
             }
    end

    test "when there's no spotlight running", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :current))

      assert json_response(conn, 404) == %{"error" => "Spotlight not found"}
    end

    test "when a spotlight exists, but is not running", %{user: user, company: company} do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      # Start a spotlight for the company
      Interaction.start_spotlight(company, -1)
      spotlight = Interaction.get_spotlight()
      assert spotlight != nil

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :current))

      assert json_response(conn, 404) == %{"error" => "Spotlight not found"}
    end

    test "when the user is not authenticated" do
      conn = build_conn()

      conn =
        conn
        |> get(Routes.spotlight_path(conn, :current))

      assert json_response(conn, 404) == %{"error" => "Spotlight not found"}
    end
  end

  describe "create" do
    test "when user is an admin", %{user: user, company: company} do
      _staff = insert(:staff, user: user, is_admin: true)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}
    end

    test "when user is a staff", %{user: user, company: company} do
      _staff = insert(:staff, user: user, is_admin: false)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when user is an attendee", %{user: user, company: company} do
      _attendee = insert(:attendee, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when user is a company", %{user: user, company: company} do
      _company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when user is a company creating a spotlight for itself", %{user: user} do
      company = insert(:company, user: user)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 401) == %{"error" => "Cannot access resource"}
    end

    test "when another spotlight is already running", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: true)
      company = insert(:company, remaining_spotlights: 2)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 422) == %{
               "errors" => %{"end" => ["Another spotlight is still active"]}
             }

      # Ensure the current spotlight was not deleted by this creation try
      spotlights = Repo.all(Spotlight)
      assert length(spotlights) == 1
    end

    test "when there's a spotlight, but has already ended", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: true)
      company = insert(:company, remaining_spotlights: 2)

      %{conn: conn, user: _user} = api_authenticate(user)

      attrs = %{"duration" => -1}

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company), attrs)

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      # Ensure there's always only one spotlight (one line at the table)
      spotlights = Repo.all(Spotlight)
      assert length(spotlights) == 1
    end

    test "when the company does not have more remaining spotlights", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: true)
      company = insert(:company, remaining_spotlights: 0)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 422) == %{
               "errors" => %{"remaining_spotlights" => ["must be greater than or equal to 0"]}
             }
    end

    test "when the company trying to create already has a spotlight", %{user: user} do
      _staff = insert(:staff, user: user, is_admin: true)
      company = insert(:company, remaining_spotlights: 2)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 422) == %{
               "errors" => %{"end" => ["Another spotlight is still active"]}
             }

      # Ensure the current spotlight was not deleted by this creation try
      spotlights = Repo.all(Spotlight)
      assert length(spotlights) == 1
    end

    test "when a badge is given within a spotlight by an admin", %{user: user} do
      admin = insert(:staff, user: user, is_admin: true)
      company = insert(:company, remaining_spotlights: 1)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      # Give badge to attendee within spotlight
      Contest.create_redeem(
        %{
          attendee_id: attendee.id,
          staff_id: admin.id,
          badge_id: company.badge_id
        },
        :admin
      )

      # Get attendee again, since it was only in-memory
      attendee = Repo.get_by!(Attendee, id: attendee.id)

      assert attendee.token_balance == ceil(company.badge.tokens * get_multiplier(company))
    end

    test "when a badge is give within a spotlight, but by a staff", %{user: user} do
      _admin = insert(:staff, user: user, is_admin: true)
      staff = insert(:staff, is_admin: false)
      company = insert(:company, remaining_spotlights: 1)
      attendee = insert(:attendee)

      %{conn: conn, user: _user} = api_authenticate(user)

      conn =
        conn
        |> post(Routes.spotlight_path(conn, :create, company))

      assert json_response(conn, 201) == %{"spotlight" => "Spotlight created successfully"}

      # Give badge to attendee within spotlight
      Contest.create_redeem(
        %{
          attendee_id: attendee.id,
          staff_id: staff.id,
          badge_id: company.badge_id
        },
        :staff
      )

      # Get attendee again, since it was only in-memory
      attendee = Repo.get_by!(Attendee, id: attendee.id)

      assert attendee.token_balance == ceil(company.badge.tokens * get_multiplier(company))
    end

    test "when a badge is given while there are no spotlights", %{user: user} do
      staff = insert(:staff, user: user, is_admin: false)
      company = insert(:company)
      attendee = insert(:attendee)

      # Give badge to attendee within spotlight
      Contest.create_redeem(
        %{
          attendee_id: attendee.id,
          staff_id: staff.id,
          badge_id: company.badge_id
        },
        :staff
      )

      # Get attendee again, since it was only in-memory
      attendee = Repo.get_by!(Attendee, id: attendee.id)

      assert attendee.token_balance == company.badge.tokens
    end

    defp get_multiplier(company) do
      case company.sponsorship do
        "Exclusive" -> 2
        "Gold" -> 1.8
        "Silver" -> 1.5
        "Bronze" -> 1
      end
    end
  end
end
