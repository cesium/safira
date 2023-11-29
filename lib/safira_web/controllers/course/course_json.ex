defmodule SafiraWeb.CourseJSON do
  @moduledoc false

  def index(%{courses: courses}) do
    %{data: for(course <- courses, do: data(course))}
  end

  def data(course) do
    %{
      id: course.id,
      name: course.name
    }
  end
end
