defmodule SafiraWeb.AuthView do
  use SafiraWeb, :view
  alias Safira.Avatar

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end

  def render("attendee.json", %{user: user}) do
    %{id: user.attendee.id,
      nick: user.attendee.nickname,
      avatar: Avatar.url({user.attendee.avatar, user.attendee}, :original),
      email: user.email}

  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
