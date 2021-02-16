defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Store
  alias Safira.Accounts

  action_fallback(SafiraWeb.FallbackController)

  def index(conn, _params) do
    redeemables = Store.list_store_redeemables()
    render(conn, "index.json", redeemables: redeemables)
  end

  def show(conn, %{"id" => id}) do
    redeemable = Store.get_redeemable!(id)
    render(conn, "show.json", redeemable: redeemable)
  end

  def my_items(conn, _params) do
    attendee = Accounts.get_user(conn)
                |> Map.fetch!(:attendee)
    cond do
      not is_nil(attendee) -> 
        redeemables = Store.get_attendee_redeemables(attendee)
        render(conn, "index_my_redeemables.json", redeemables: redeemables)
      true ->
        conn
          |> put_status(:unauthorized)
          |> json(%{error: "Only attendees can have products!"})
    end
  end

end
