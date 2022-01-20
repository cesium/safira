defmodule SafiraWeb.CvController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Cv
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def show(conn, _params) do
    user = Accounts.get_user(conn)
  end

  def update(conn, params) do
    user = Accounts.get_user(conn)

    Contest.update_cv(user.attendee.id, params)
  end

  def delete(conn, _params) do
    user = Accounts.get_user(conn)

    with {:ok, _} <- Contest.delete_by_user_id!(user.attendee.id) do
      send_resp(conn, :no_content, "")
    end
  end
end
