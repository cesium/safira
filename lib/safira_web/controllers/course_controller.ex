defmodule SafiraWeb.CourseController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def index(conn, _params) do
    courses = Accounts.list_courses()
    render(conn, "index.json", courses: courses)
  end
end
