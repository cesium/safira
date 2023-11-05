defmodule SafiraWeb.CompanyJSON do
  @moduledoc false

  alias SafiraWeb.AttendeeJSON

  def index(%{companies: companies}) do
    %{data: for(c <- companies, do: company_show(%{company: c}))}
  end

  def show(%{company: company}) do
    %{data: company_show(%{company: company})}
  end

  def company_show(%{company: company}) do
    %{
      id: company.id,
      name: company.name,
      sponsorship: company.sponsorship,
      channel_id: company.channel_id,
      badge_id: company.badge_id,
      has_cv_access: company.has_cv_access
    }
  end

  def index_attendees(%{attendees: attendees, show_cv: show_cv}) do
    if show_cv do
      %{data: for(at <- attendees, do: AttendeeJSON.attendee_simple(%{attendee: at}))}
    else
      %{data: for(at <- attendees, do: AttendeeJSON.attendee_no_cv(%{attendee: at}))}
    end
  end
end
