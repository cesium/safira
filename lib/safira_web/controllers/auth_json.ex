defmodule SafiraWeb.AuthJSON do
  @moduledoc false

  alias SafiraWeb.AttendeeView
  alias SafiraWeb.CompanyView

  def signup_response(%{
        jwt: jwt,
        discord_association_code: discord_association_code
      }) do
    %{jwt: jwt, discord_association_code: discord_association_code}
  end

  def data(%{user: %{type: "attendee", attendee: attendee}} = user) do
    user_data(user)
    |> Map.merge(AttendeeView.render("attendee.json", attendee: attendee))
  end

  def data(%{user: %{type: "company", company: company}} = user) do
    user_data(user)
    |> Map.merge(CompanyView.render("company.json", company: company))
  end

  def data(%{user: %{type: "staff", staff: staff}} = user) do
    user_data(user)
    |> Map.merge(%{is_admin: staff.is_admin})
  end

  defp user_data(%{user: user}) do
    %{
      id: user.id,
      email: user.email,
      type: user.type
    }
  end

  def is_registered(%{is_registered: value}) do
    %{is_registered: value}
  end

  def jwt(%{jwt: jwt}) do
    %{jwt: jwt}
  end
end
