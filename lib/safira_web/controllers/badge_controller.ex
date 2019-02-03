defmodule SafiraWeb.BadgeController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Accounts.User
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    cond do
      is_manager(conn) ->
        badges = Contest.list_badges()
        render(conn, "index.json", badges: badges)
      true -> 
        badges = Contest.list_badges_conservative()
        render(conn, "index.json", badges: badges)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Contest.get_badge!(id)
    render(conn, "show.json", badge: badge)
  end

  defp get_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> Accounts.get_user_preload!()
    end
  end

  defp is_manager(conn) do
    get_user(conn)
    |> Map.fetch!(:manager)
    |> is_nil 
    |> Kernel.not
  end

  defp is_attendee(conn) do
    get_user(conn)
    |> Map.fetch!(:manager)
    |> is_nil 
    |> Kernel.not
  end
end
