defmodule SafiraWeb.LeaderboardView do
  use SafiraWeb, :view
  alias SafiraWeb.LeaderboardView
  alias Safira.Avatar

  def render("index.json", %{attendees: attendees}) do
    %{data: render_many(attendees, LeaderboardView, "attendee.json", as: :attendee)}
  end

  def render("attendee.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: attendee.badge_count,
      volunteer: attendee.volunteer
    }
  end
end
