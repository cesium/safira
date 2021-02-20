defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Store
  alias Safira.Accounts

  action_fallback(SafiraWeb.FallbackController)

  def index(conn, _params) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)
    redeemables = Store.list_store_redeemables(attendee)
    render(conn, "index.json", redeemables: redeemables)
  end

  def show(conn, %{"id" => id}) do
    redeemable = Store.get_redeemable!(id)
    render(conn, "show.json", redeemable: redeemable)
  end
end
