defmodule SafiraWeb.Backoffice.BadgeLive.RedeemLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Contest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Refund badge redeems.")}>
        <ul
          id="triggers"
          phx-update="stream"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
        >
          <li
            :for={{id, redeem} <- @streams.redeems}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between items-center"
          >
            <%!-- <p class="text-dark dark:text-light flex flex-row justify-between"> --%>
            <%!-- <%= trigger_description(redeem) %> --%>
            <%!-- </p> --%>
            <.avatar
              src={Safira.Uploaders.UserPicture.url({redeem.attendee.user.picture, redeem.attendee.user}, :original, signed: true)}
              handle={redeem.attendee.user.handle}
              class="w-8 h-8"
            />
            <p>
              <%= redeem.redeemed_by.user.handle %>
            </p>
            <p>
              <%= redeem.attendee.user.handle %>
            </p>
            <div class="flex flex-row gap-2 justify-between">
              <.link
                phx-click={JS.push("delete", value: %{id: redeem.id}) |> hide("##{id}")}
                phx-target={@myself}
                data-confirm="Are you sure?"
              >
                <.icon name="hero-trash" class="w-5 h-5" />
              </.link>
            </div>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              <%= gettext("No triggers set for this badge.") %>
            </p>
          </div>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> stream(
       :redeems,
       Contest.list_badge_redeems(assigns.badge.id)
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    badge_redeem = Contest.get_badge_redeem!(id)

    case Contest.revoke_badge_redeem_from_attendee(id) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :redeems, badge_redeem)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  defp trigger_description(trigger) do
    gettext("Award when attendee %{event_description}.",
      event_description: event_text(trigger.event)
    )
  end

  defp event_text(event) do
    case event do
      :upload_cv_event ->
        gettext("uploads their cv")

      :play_slots_event ->
        gettext("plays the slots minigame")

      :play_coin_flip_event ->
        gettext("plays the coin flip minigame")

      :play_wheel_event ->
        gettext("plays the wheel minigame")

      :redeem_spotlighted_badge_event ->
        gettext("redeems the badge of a company that is on spotlight")

      :link_credential_event ->
        gettext("links their credential")

      _ ->
        event
    end
  end
end
