defmodule SafiraWeb.AttendeeView do
  use SafiraWeb, :view
  alias SafiraWeb.AttendeeView

  def render("index.json", %{attendees: attendees}) do
    %{data: render_many(attendees, AttendeeView, "attendee.json")}
  end

  def render("show.json", %{attendee: attendee}) do
    %{data: render_one(attendee, AttendeeView, "attendee.json")}
  end

  def render("attendee.json", %{attendee: attendee}) do
    %{id: attendee.id,
      nickname: attendee.nickname}
  end
end
