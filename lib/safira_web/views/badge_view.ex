defmodule SafiraWeb.BadgeView do
  use SafiraWeb, :view
  alias SafiraWeb.BadgeView
  alias Safira.Avatar

  def render("index.json", %{badges: badges}) do
    %{data: render_many(badges, BadgeView, "badge.json")}
  end

  def render("show.json", %{badge: badge}) do
    %{data: render_one(badge, BadgeView, "badge.json")}
  end

  def render("badge.json", %{badge: badge}) do
    %{id: badge.id,
      name: badge.name,
      description: badge.description,
      avatar: Avatar.url({badge.avatar, badge}, :original),
      begin: badge.begin,
      end: badge.end
    }
  end
end
