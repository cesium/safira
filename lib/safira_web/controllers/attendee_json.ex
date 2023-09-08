defmodule SafiraWeb.AttendeeJSON do
  @moduledoc false

  alias Safira.Avatar

  alias Safira.CV

  alias SafiraWeb.BadgeJSON
  alias SafiraWeb.PrizeJSON
  alias SafiraWeb.RedeemableJSON

  def index(%{attendees: attendees}) do
    %{data: for(at <- attendees, do: multiple_attendees(%{attendee: at}))}
  end

  def show(%{attendee: at}) do
    %{data: attendee(%{attendee: at})}
  end

  def show_simple(%{attendee: at}) do
    %{data: attendee_simple(%{attendee: at})}
  end

  def manager_show(%{attendee: at}) do
    %{data: manager_attendee(%{attendee: at})}
  end

  def attendee(%{attendee: at}) do
    %{
      id: at.id,
      nickname: at.nickname,
      name: at.name,
      avatar: Avatar.url({at.avatar, at}, :original),
      course: at.course_id,
      cv: CV.url({at.cv, at}, :original),
      badges: for(b <- at.badges, do: BadgeJSON.badge(%{badge: b})),
      badge_count: at.badge_count,
      token_balance: at.token_balance,
      prizes: for(p <- at.prizes, do: PrizeJSON.prize_attendee(%{prize: p})),
      entries: at.entries,
      redeemables: for(r <- at.redeemables, do: RedeemableJSON.my_readeemables(%{redeemable: r}))
    }
  end

  def multiple_attendees(%{attendee: at}) do
    %{
      id: at.id,
      nickname: at.nickname,
      name: at.name,
      avatar: Avatar.url({at.avatar, at}, :original),
      course: at.course_id,
      cv: CV.url({at.cv, at}, :original),
      badges: for(b <- at.badges, do: BadgeJSON.badge(%{badge: b})),
      badge_count: at.badge_count,
      token_balance: at.token_balance,
      entries: at.entries
    }
  end

  def manager_attendee(%{attendee: at}) do
    %{
      id: at.id,
      nickname: at.nickname,
      name: at.name,
      email: at.user.email,
      avatar: Avatar.url({at.avatar, at}, :original),
      cv: CV.url({at.cv, at}, :original),
      badges: for(b <- at.badges, do: BadgeJSON.badge(%{badge: b})),
      badge_count: at.badge_count
    }
  end

  def attendee_simple(%{attendee: at}) do
    %{
      id: at.id,
      nickname: at.nickname,
      name: at.name,
      avatar: Avatar.url({at.avatar, at}, :original),
      course: at.course_id,
      cv: CV.url({at.cv, at}, :original),
      token_balance: at.token_balance,
      entries: at.entries
    }
  end

  def attendee_no_cv(%{attendee: at}) do
    %{
      id: at.id,
      nickname: at.nickname,
      name: at.name,
      avatar: Avatar.url({at.avatar, at}, :original),
      course: at.course_id,
      cv: nil,
      token_balance: at.token_balance,
      entries: at.entries
    }
  end
end
