defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Contest
  alias Safira.Accounts.User
  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
      redeemables = Contest.list_redeemables()
      render(conn, "index.json",redeemables: redeemables)
  end

  def show(conn, %{"id" => id}) do
      redeemable = Contest.get_redeemable!(id)
      render(conn, "show.json", redeemable: redeemable)
  end
end