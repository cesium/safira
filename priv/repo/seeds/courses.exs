defmodule Safira.Repo.Seeds.Courses do
  alias Safira.Accounts

  @courses File.read!("priv/fake/courses.txt") |> String.split("\n")

  def run do
    case Accounts.list_courses() do
      [] ->
        seed_courses()

      _ ->
        Mix.shell().error("Found courses, aborting seeding courses.")
    end
  end

  defp seed_courses do
    @courses
    |> Enum.each(fn course ->
      %{
        name: course
      }
      |> Accounts.create_course()
    end)
  end
end

Safira.Repo.Seeds.Courses.run()
