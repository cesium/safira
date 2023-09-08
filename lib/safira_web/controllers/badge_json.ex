defmodule SafiraWeb.BadgeJSON do
  alias SafiraWeb.AttendeeJSON
  alias Safira.Avatar

  def index(%{badges: badges}) do
    %{data: for(b <- badges, do: badge(%{badge: b}))}
  end

  def show(%{badge: badge}) do
    %{data: badge_show(%{badge: badge})}
  end

  def badge(%{badge: badge}) do
    %{
      id: badge.id,
      name: badge.name,
      description: badge.description,
      avatar: Avatar.url({badge.avatar, badge}, :original),
      begin: badge.begin,
      end: badge.end,
      type: badge.type,
      tokens: badge.tokens
    }
  end

  def badge_show(%{badge: badge}) do
    %{
      id: badge.id,
      name: badge.name,
      description: badge.description,
      avatar: Avatar.url({badge.avatar, badge}, :original),
      begin: badge.begin,
      end: badge.end,
      type: badge.type,
      tokens: badge.tokens,
      attendees: for(at <- badge.attendees, do: AttendeeJSON.attendee_simple(%{attendee: at}))
    }
  end
end
