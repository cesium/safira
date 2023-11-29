defmodule SafiraWeb.CourseController do
  use SafiraWeb, :controller

  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    courses = Accounts.list_courses()
    render(conn, :index, courses: courses)
  end
end
