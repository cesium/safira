defmodule SafiraWeb.RedeemableController do
  use SafiraWeb, :controller

  alias Safira.Store
  alias Safira.Accounts

  action_fallback(SafiraWeb.FallbackController)

  def index(conn, _params) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)
    cond do
      not is_nil(attendee) ->
        redeemables = Store.list_store_redeemables(attendee)
        render(conn, "index.json", redeemables: redeemables)

      true ->
        redeemables = Store.list_redeemables()
        render(conn,"index_non_attendee.json",redeemables: redeemables)
    end
  end

  def show(conn, %{"id" => id}) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)
      cond do
        not is_nil(attendee) ->
          redeemable = Store.get_redeemable_attendee(id,attendee)
          render(conn, "show.json", redeemable: redeemable)

        true ->
          redeemable = Store.get_redeemable!(id)
          render(conn, "show_non_attendee.json", redeemable: redeemable)
      end

  end

  def show_unredeemed(conn, _params) do
    attendee =
      Accounts.get_user(conn)
      |> Map.fetch!(:attendee)
    cond do
      not is_nil(attendee) ->
        redeemables = Store.get_attendee_not_redemed(attendee)
        ## this is probably wrong but i don't know how to check
        render(conn, "show.json", redeemable: redeemable)
      true ->
        conn
          |> put_status(:bad_request)
          |> json(%{Error: "Wrong attendee"})
      end
  end

end
