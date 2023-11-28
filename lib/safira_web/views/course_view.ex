defmodule SafiraWeb.CourseView do
  use SafiraWeb, :view

  alias SafiraWeb.CourseView

  def render("index.json", %{courses: courses}) do
    %{data: render_many(courses, CourseView, "course.json")}
  end

  def render("course.json", %{course: course}) do
    %{
      id: course.id,
      name: course.name
    }
  end
end
