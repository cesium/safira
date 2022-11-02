defmodule SafiraWeb.AttendeeView do
  use SafiraWeb, :view

  alias Safira.Avatar
  alias SafiraWeb.AttendeeView

  def render("index.json", %{attendees: attendees}) do
    %{data: render_many(attendees, AttendeeView, "attendees.json")}
  end

  def render("show.json", %{attendee: attendee}) do
    %{data: render_one(attendee, AttendeeView, "attendee.json")}
  end

  def render("show_simple.json", %{attendee: attendee}) do
    %{data: render_one(attendee, AttendeeView, "attendee_simple.json")}
  end

  def render("manager_show.json", %{attendee: attendee}) do
    %{data: render_one(attendee, AttendeeView, "manager_attendee.json")}
  end

  def render("attendee.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: render_many(attendee.badges, SafiraWeb.BadgeView, "badge.json"),
      badge_count: attendee.badge_count,
      volunteer: attendee.volunteer,
      token_balance: attendee.token_balance,
      prizes: render_many(attendee.prizes, SafiraWeb.PrizeView, "prize_attendee.json"),
      entries: attendee.entries,
      redeemables:
        render_many(attendee.redeemables, SafiraWeb.RedeemableView, "my_redeemables.json")
    }
  end

  def render("attendees.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: render_many(attendee.badges, SafiraWeb.BadgeView, "badge.json"),
      badge_count: attendee.badge_count,
      volunteer: attendee.volunteer,
      token_balance: attendee.token_balance,
      # prizes: render_many(attendee.prizes, SafiraWeb.PrizeView, "prize.json"),
      entries: attendee.entries
      # redeemables: render_many(attendee.redeemables, SafiraWeb.RedeemableView, "my_redeemables.json")
    }
  end

  def render("manager_attendee.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      email: attendee.user.email,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      badges: render_many(attendee.badges, SafiraWeb.BadgeView, "badge.json"),
      badge_count: attendee.badge_count,
      volunteer: attendee.volunteer
    }
  end

  def render("attendee_simple.json", %{attendee: attendee}) do
    %{
      id: attendee.id,
      nickname: attendee.nickname,
      name: attendee.name,
      avatar: Avatar.url({attendee.avatar, attendee}, :original),
      # volunteer: attendee.volunteer,
      token_balance: attendee.token_balance,
      entries: attendee.entries
    }
  end
end
