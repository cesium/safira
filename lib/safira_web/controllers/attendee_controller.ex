defmodule SafiraWeb.AttendeeController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.User

  alias Safira.Roulette

  alias Safira.Store

  action_fallback SafiraWeb.FallbackController
  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  def index(conn, _params) do
    attendees = Accounts.list_active_attendees()
    render(conn, "index.json", attendees: attendees)
  end

  def show(conn, %{"id" => id}) do
    attendee =
      case String.match?(id, @uuid_regex) do
        true ->
          Accounts.get_attendee_with_badge_count_by_id!(id)

        _ ->
          Accounts.get_attendee_by_username!(id)
      end

    cond do
      is_nil(attendee) ->
        {:error, :not_found}

      is_nil(attendee.user_id) ->
        {:error, :not_registered}

      Accounts.is_staff(conn) ->
        render(conn, "staff_show.json", attendee: attendee)

      true ->
        attendee =
          attendee
          |> Map.put(:redeemables, Store.get_attendee_redeemables(attendee))
          |> Map.put(:prizes, Roulette.get_attendee_prize(attendee))

        render(conn, "show.json", attendee: attendee)
    end
  end

  def update(conn, %{"id" => id, "attendee" => attendee_params}) do
    user = Accounts.get_user(conn)
    attendee = Accounts.get_attendee!(id)

    if user.attendee.id == attendee.id do
      with {:ok, %Attendee{} = attendee} <-
             Accounts.update_attendee(attendee, attendee_params) do
        render(conn, "show_simple.json", attendee: attendee)
      end
    else
      {:error, :unauthorized}
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(conn)
    user_attendee = Accounts.get_attendee!(user.attendee.id)
    attendee = Accounts.get_attendee!(id)

    if user_attendee == attendee do
      with {:ok, %Attendee{}} <- Accounts.delete_attendee(attendee),
           {:ok, %User{}} <- Accounts.delete_user(user) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:no_content, Poison.encode!(""))
      end
    else
      {:error, :no_permission}
    end
  end
end
