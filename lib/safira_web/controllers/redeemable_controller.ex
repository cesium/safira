defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Store

  action_fallback(SafiraWeb.FallbackController)

  def index(conn, _params) do
    redeemables = Store.list_redeemables()
    render(conn, "index.json", redeemables: redeemables)
  end

  def show(conn, %{"id" => id}) do
    redeemable = Store.get_redeemable!(id)
    render(conn, "show.json", redeemable: redeemable)
  end
end
