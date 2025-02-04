defmodule SafiraWeb.Sponsor.HomeLive.Index do
  use SafiraWeb, :sponsor_view

  alias Safira.Contest

  import SafiraWeb.Sponsor.HomeLive.Components.Attendee
  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    badge_id = socket.assigns.current_user.company.badge_id

    if is_nil(badge_id) do
      {:noreply,
         socket
         |> assign(:current_page, :visitors)
         |> assign(:params, params)
         |> assign(:meta, %Flop.Meta{current_offset: 0, current_page: 0})
         |> stream(:redeems, [], reset: true)}
    else
      case Contest.list_badge_redeems_meta(socket.assigns.current_user.company.badge_id, params) do
        {:ok, {redeems, meta}} ->
          {:noreply,
          socket
          |> assign(:current_page, :visitors)
          |> assign(:meta, meta)
          |> assign(:params, params)
          |> stream(:redeems, redeems, reset: true)}

        {:error, _} ->
          {:error, socket}
      end
    end
  end
end
