defmodule SafiraWeb.CompanyView do
  use SafiraWeb, :view
  alias SafiraWeb.CompanyView

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
    }
  end
end
