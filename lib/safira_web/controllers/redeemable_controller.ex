defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Accounts

  alias Safira.Store

  action_fallback(SafiraWeb.FallbackController)

  def index(conn, _params) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)

    if is_nil(attendee) do
      redeemables = Store.list_redeemables()
      render(conn, "index_non_attendee.json", redeemables: redeemables)
    else
      redeemables = Store.list_store_redeemables(attendee)
      render(conn, "index.json", redeemables: redeemables)
    end
  end

  def show(conn, %{"id" => id}) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)

    if is_nil(attendee) do
      redeemable = Store.get_redeemable!(id)
      render(conn, "show_non_attendee.json", redeemable: redeemable)
    else
      redeemable = Store.get_redeemable_attendee(id, attendee)
      render(conn, "show.json", redeemable: redeemable)
    end
  end
end
