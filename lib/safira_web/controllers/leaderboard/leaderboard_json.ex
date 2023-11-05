defmodule SafiraWeb.LeaderboardJSON do
  @moduledoc false

  alias Safira.Avatar

  def index(%{attendees: attendees}) do
    %{data: for(at <- attendees, do: attendee(%{attendee: at}))}
  end

  def attendee(%{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: attendee.badge_count,
      token_balance: attendee.token_balance
    }
  end
end
