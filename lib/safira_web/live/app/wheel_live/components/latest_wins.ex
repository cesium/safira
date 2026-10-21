defmodule SafiraWeb.App.WheelLive.Components.LatestWins do
  @moduledoc """
  Lucky wheel latest wins component.
  """
  use SafiraWeb, :component
  import SafiraWeb.Components.Avatar

  attr :entries, :list, default: []

  def latest_wins(assigns) do
    ~H"""
    <ul class="w-full divide-y divide-light/5 border-t border-light/10">
      <%= for entry <- @entries do %>
        <li class="flex flex-row w-full lg:gap-4 py-4 lg:px-4 items-center justify-between">
          <.link
            navigate={~p"/app/user/#{entry.attendee.user.handle}"}
            class="flex gap-4 flex-center items-center min-w-0"
          >
            <.avatar
              handle={entry.attendee.user.handle}
              size={:sm}
              src={
                Uploaders.UserPicture.url(
                  {entry.attendee.user.picture, entry.attendee.user},
                  :original,
                  signed: true
                )
              }
            />
            <div class="self-center min-w-0">
              <p class="text-sm lg:text-base font-semibold truncate">{entry.attendee.user.name}</p>
              <p class="text-sm lg:text-base font-normal text-light/50 truncate">
                @{entry.attendee.user.handle}
              </p>
            </div>
          </.link>

          <div class="text-right">
            <p class=" text-light">{entry_name(entry)}</p>
            <p class="text-xs lg:text-sm text-light/50 shrink-0">
              {relative_datetime(entry.inserted_at)}
            </p>
          </div>
        </li>
      <% end %>
      <li class="hidden only:flex w-full h-full flex-col items-center justify-center py-16 opacity-80 text-light/70">
        {gettext("No wins yet. Be the first to win!")}
      </li>
    </ul>
    """
  end

  defp entry_name(entry) do
    if is_nil(entry.drop.badge) do
      entry.drop.prize.name
    else
      entry.drop.badge.name
    end
  end
end
