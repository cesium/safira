defmodule SafiraWeb.AuthJSON do
  @moduledoc false

  alias Safira.Avatar

  def data(%{user: user}) do
    %{
      id: user.id,
      email: user.email,
      type: user.type
    }
  end

  def is_registered(%{is_registered: value}) do
    %{is_registered: value}
  end

  def attendee(%{user: user}) do
    %{
      id: user.attendee.id,
      nickname: user.attendee.nickname,
      name: user.attendee.name,
      avatar: Avatar.url({user.attendee.avatar, user.attendee}, :original),
      email: user.email
    }
  end

  def company(%{user: user}) do
    %{
      id: user.company.id,
      name: user.company.name,
      email: user.email,
      sponsorship: user.company.sponsorship,
      badge_id: user.company.badge_id
    }
  end

  def jwt(%{jwt: jwt}) do
    %{jwt: jwt}
  end

  def signup_response(%{
        jwt: jwt,
        discord_association_code: discord_association_code
      }) do
    %{jwt: jwt, discord_association_code: discord_association_code}
  end
end
