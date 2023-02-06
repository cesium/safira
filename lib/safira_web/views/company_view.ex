defmodule SafiraWeb.CompanyView do
  use SafiraWeb, :view
  alias SafiraWeb.CompanyView

  alias SafiraWeb.AttendeeView

  def render("index.json", %{companies: companies}) do
    %{data: render_many(companies, CompanyView, "company.json")}
  end

  def render("show.json", %{company: company}) do
    %{data: render_one(company, CompanyView, "company.json")}
  end

  def render("company.json", %{company: company}) do
    %{
      id: company.id,
      name: company.name,
      sponsorship: company.sponsorship,
      channel_id: company.channel_id,
      badge_id: company.badge_id,
      has_cv_access: company.has_cv_access
    }
  end

  def render("index_attendees.json", %{attendees: attendees, show_cv: show_cv}) do
    if show_cv do
      %{data: render_many(attendees, AttendeeView, "attendee_simple.json")}
    else
      %{data: render_many(attendees, AttendeeView, "attendee_no_cv.json")}
    end
  end
end
