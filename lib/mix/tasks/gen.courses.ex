defmodule Mix.Tasks.Gen.Courses do
  @moduledoc """
  Task to generate university courses
  """
  use Mix.Task

  alias Safira.Accounts

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs to receive atleast one file path.")
    else
      args |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_txt()
    |> insert_courses()
  end

  defp parse_txt(path) do
    path
    |> File.read!()
    |> String.split("\n")
  end

  defp insert_courses(courses) do
    Enum.each(courses, fn course ->
      Accounts.create_course(%{
        "name" => course
      })
    end)
  end
end
