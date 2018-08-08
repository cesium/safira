defmodule SafiraWeb.AuthView do
  use SafiraWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end

  def render("attendee.json", %{user: user}) do
    %{id: user.attendee.id,
      nick: user.attendee.nickname,
      email: user.email}
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
