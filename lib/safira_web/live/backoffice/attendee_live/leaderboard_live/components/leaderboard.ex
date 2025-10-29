defmodule SafiraWeb.Backoffice.LeaderboardLive.Components.Leaderboard do
  @moduledoc """
  Leaderboard component
  """

  use SafiraWeb, :component

  import SafiraWeb.Components.Avatar

  attr :entries, :list, required: true

  def leaderboard(assigns) do
    ~H"""
    <div class="w-full">
      <.leaderboard_top_3 entries={Enum.take(@entries, 3)} />
      <ul class="flex flex-col gap-4 mt-6">
        <.leaderboard_entry :for={entry <- Enum.drop(@entries, 3)} entry={entry} />
      </ul>
    </div>
    """
  end

  defp leaderboard_top_3(assigns) do
    ~H"""
    <div class="flex flex-row justify-between w-full">
      <.leaderboard_top_person entry={Enum.at(@entries, 1)} pos={2} />
      <.leaderboard_top_person entry={Enum.at(@entries, 0)} winner={true} pos={1} />
      <.leaderboard_top_person entry={Enum.at(@entries, 2)} pos={3} />
    </div>
    """
  end

  attr :entry, :map, required: true
  attr :winner, :boolean, default: false
  attr :pos, :integer, required: true

  defp leaderboard_top_person(assigns) do
    ~H"""
    <%= if @entry do %>
      <div class={["flex flex-col w-full items-center mt-8 mb-4", @winner && "-translate-y-20"]}>
        <.icon
          :if={@winner}
          name="fa-crown fa-crown-solid"
          class="w-10 h-10 translate-y-6 text-accent"
        />
        <.avatar
          handle={@entry.handle}
          size={:xl}
          class="bg-light/5 border-2 border-accent bg-accent rounded-full"
          link={~p"/dashboard/attendees/#{@entry.attendee_id}"}
        />
        <span class="bg-accent rounded-full px-2 -translate-y-3 select-none text-primary/80 font-semibold border-primary border-2">
          {@pos}
        </span>
        <p class="font-semibold truncate max-w-28 sm:max-w-full">{@entry.name}</p>
        <p class="font-bold">
          {gettext("%{badges_count} badges", badges_count: @entry.badges)}
        </p>
        <p class="font-medium">
          {gettext("%{tokens} tokens", tokens: @entry.tokens)}
        </p>
      </div>
    <% end %>
    """
  end

  attr :entry, :map, required: true

  defp leaderboard_entry(assigns) do
    ~H"""
    <li class="flex flex-row py-3 px-4 rounded-lg justify-between items-center bg-darkMuted/5 dark:bg-light/5 text-dark dark:text-light">
      <div class="flex flex-row gap-4 items-center">
        <p class="font-bold text-xl">
          #{@entry.position}
        </p>
        <p>
          <.avatar
            handle={@entry.handle}
            size={:sm}
            class="bg-light/5 border-2 border-light/5 rounded-full"
            link={~p"/app/user/#{@entry.handle}"}
          />
        </p>
        <.link patch={~p"/dashboard/attendees/#{@entry.attendee_id}"}>
          <p class="font-semibold truncate max-w-40">
            {@entry.name}
          </p>
        </.link>
      </div>
      <div>
        <p class="font-semibold flex sm:flex-row flex-col items-center gap-2">
          <span>
            {@entry.badges}
            <span>
              {gettext(" badges")}
            </span>
          </span>
          <span class="font-medium text-sm">
            {@entry.tokens}
            <span>
              {gettext(" tokens")}
            </span>
          </span>
        </p>
      </div>
    </li>
    """
  end
end
