defmodule SafiraWeb.UsersLive do
  alias Safira.Accounts
  use SafiraWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_staffs())}
  end
end
