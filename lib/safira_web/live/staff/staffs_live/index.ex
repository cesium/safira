defmodule SafiraWeb.StaffsLive.Index do
  alias Safira.Accounts
  use SafiraWeb, :live_view

  import SafiraWeb.Components.Table

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_staffs(params) do
      {:ok, {staffs, meta}} ->
        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:staffs, staffs, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
