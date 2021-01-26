defmodule SafiraWeb.AuthView do
  use SafiraWeb, :view
  alias Safira.Avatar

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      type: user.type
    }
  end

  def render("is_registered.json", %{is_registered: value}) do
    %{is_registered: value}
  end

  def render("attendee.json", %{user: user}) do
    %{
      id: user.attendee.id,
      nickname: user.attendee.nickname,
      name: user.attendee.name,
      avatar: Avatar.url({user.attendee.avatar, user.attendee}, :original),
      email: user.email
    }
  end

  def render("company.json", %{user: user}) do
    %{
      id: user.company.id,
      name: user.company.name,
      email: user.email,
      sponsorship: user.company.sponsorship,
      badge_id: user.company.badge_id
    }
  end

  def render("signup_response.json", %{jwt: jwt, association_code: association_code}) do
    %{jwt: jwt,
      association_code: association_code}
  end
end
