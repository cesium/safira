defmodule SafiraWeb.AttendeeController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.User
  alias Safira.Contest
  alias Safira.Contest.Redeem

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    attendees = Accounts.list_attendees()
    render(conn, "index.json", attendees: attendees)
  end

  def create(conn, %{"attendee" => attendee_params}) do
    with {:ok, %Attendee{} = attendee} <- Accounts.create_attendee(attendee_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", attendee_path(conn, :show, attendee))
      |> render("show.json", attendee: attendee)
    end
  end

  def show(conn, %{"id" => id}) do
    attendee = Accounts.get_attendee!(id)
    cond do
      is_nil attendee.user_id ->
        {:error, :not_registered}
      is_company(conn) ->
        with :ok <- redeem_company_badge(conn, id) do
          render(conn, "show.json", attendee: attendee)
        end
      true ->
        render(conn, "show.json", attendee: attendee)
    end
  end

  def update(conn, %{"id" => id, "attendee" => attendee_params}) do
    attendee = Accounts.get_attendee!(id)

    if get_user(conn).attendee == attendee do
      with {:ok, %Attendee{} = attendee} <- 
          Accounts.update_attendee(attendee, attendee_params) do
        render(conn, "show.json", attendee: attendee)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = get_user(conn)
    attendee = Accounts.get_attendee!(id)
    if user.attendee == attendee do
      with {:ok, %Attendee{}} <- Accounts.delete_attendee(attendee),
           {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  defp get_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> Accounts.get_user_preload!()
    end
  end

  defp is_company(conn) do
    get_user(conn)
    |> Map.fetch!(:company)
    |> is_nil 
    |> Kernel.not
  end

  defp redeem_company_badge(conn, id) do
    user = get_user(conn)
    redeem_params = %{"attendee_id" => id, "badge_id" => user.company.badge_id}
    case Contest.create_redeem(redeem_params) do
      {:ok, %Redeem{} = _redeem} ->
        :ok
      {:error, changeset} ->
        if changeset.errors == [unique_attendee_badge: {"has already been taken", []}] do
          :ok
        else
          :error
        end
    end
  end
end
