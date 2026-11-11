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
     |> assign(:all_enabled, has_all_access?(socket.assigns.current_user.company))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    badge_id = socket.assigns.current_user.company.badge_id

    all_requested = params["all"] == "true"
    all_active = socket.assigns.all_enabled and all_requested

    case list_users(all_active, badge_id, params) do
      {:ok, {users, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :visitors)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:all, all_active)
         |> assign(:form, to_form(%{"all" => all_active}))
         |> stream(:users, users, reset: true)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Invalid search parameters"))
         |> push_patch(to: ~p"/sponsor")}
    end
  end

  @impl true
  def handle_event("validate", %{"all" => all}, socket) do
    new_params =
      socket.assigns.params
      |> Map.delete("page")

    new_params =
      if string_to_bool(all) do
        Map.put(new_params, "all", "true")
      else
        Map.delete(new_params, "all")
      end

    {:noreply, push_patch(socket, to: ~p"/sponsor?#{new_params}")}
  end

  defp list_users(false, nil, _),
    do:
      {:ok,
       {[],
        %Flop.Meta{
          current_offset: 0,
          current_page: 1,
          page_size: @limit,
          total_count: 0,
          total_pages: 0,
          has_previous_page?: false,
          has_next_page?: false
        }}}

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
      image:
        Uploaders.UserPicture.url(
          {redeem.attendee.user.picture, redeem.attendee.user},
          :original,
          signed: true
        ),
      cv:
        Uploaders.CV.url({redeem.attendee.user.cv, redeem.attendee.user}, :original, signed: true)
    }
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      handle: user.handle,
      image: Uploaders.UserPicture.url({user.picture, user}, :original, signed: true),
      cv: Uploaders.CV.url({user.cv, user}, :original, signed: true)
    }
  end
end
