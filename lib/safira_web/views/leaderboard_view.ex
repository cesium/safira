defmodule SafiraWeb.LeaderboardView do
  use SafiraWeb, :view

  alias Safira.Avatar

  alias SafiraWeb.LeaderboardView

  def render("index.json", %{attendees: attendees}) do
    %{data: render_many(attendees, LeaderboardView, "attendee.json", as: :attendee)}
  end

  def render("attendee.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: attendee.badge_count,
      token_balance: attendee.token_balance,
      volunteer: attendee.volunteer
    }
  end
end
