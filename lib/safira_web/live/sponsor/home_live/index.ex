defmodule SafiraWeb.Sponsor.HomeLive.Index do
  use SafiraWeb, :sponsor_view

  alias Safira.Accounts
  alias Safira.Contest

  import SafiraWeb.Sponsor.HomeLive.Components.Attendee
  import SafiraWeb.Components.Forms
  import SafiraWeb.Components.Table
  import SafiraWeb.Components.TableSearch

  @limit 12

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:all_enabled, has_all_access?(socket.assigns.current_user.company))
     |> assign(:all, false)
     |> assign(:form, to_form(%{all: false}))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    badge_id = socket.assigns.current_user.company.badge_id

    case list_users(socket.assigns.all_enabled and socket.assigns.all, badge_id, params) do
      {:ok, {users, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :visitors)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:users, users, reset: true)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, gettext("An error occurred"))}
    end
  end

  @impl true
  def handle_event("validate", %{"all" => all}, socket) do
    badge_id = socket.assigns.current_user.company.badge_id

    case list_users(
           socket.assigns.all_enabled and string_to_bool(all),
           badge_id,
           socket.assigns.params
         ) do
      {:ok, {users, meta}} ->
        {:noreply,
         socket
         |> assign(:all, string_to_bool(all))
         |> assign(:current_page, :visitors)
         |> assign(:meta, meta)
         |> stream(:users, users, reset: true)}

      {:error, _reason} ->
        {:noreply, socket |> assign(:all, all) |> put_flash(:error, gettext("An error occurred"))}
    end
  end

  defp list_users(_, nil, _), do: {:ok, {[], %Flop.Meta{current_offset: 0, current_page: 0}}}

  defp list_users(false, badge_id, params) do
    case Contest.list_badge_redeems_meta(badge_id, Map.put(params, "page_size", @limit)) do
      {:ok, {redeems, meta}} ->
        {:ok, {Enum.map(redeems, &redeem_data/1), meta}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp list_users(true, _, params) do
    case Accounts.list_attendees(Map.put(params, "page_size", @limit)) do
      {:ok, {users, meta}} ->
        {:ok, {Enum.map(users, &user_data/1), meta}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp has_all_access?(company) do
    company.tier.full_cv_access
  end

  defp redeem_data(redeem) do
    %{
      id: redeem.id,
      name: redeem.attendee.user.name,
      handle: redeem.attendee.user.handle,
      image: nil,
      cv: Uploaders.CV.url({redeem.attendee.cv, redeem.attendee}, :original, signed: true)
    }
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      handle: user.handle,
      image: nil,
      cv: Uploaders.CV.url({user.attendee.cv, user.attendee}, :original, signed: true)
    }
  end
end
