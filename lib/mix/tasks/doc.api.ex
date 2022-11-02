defmodule Mix.Tasks.Doc.Api do
  @moduledoc """
  Task to generate documentation
  """
  use Mix.Task

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs to receive an ENV flag.")
    else
      args |> create
    end
  end

  defp create(args) do
    Mix.Task.run("app.start")
    System.cmd("bash", ["-c", "#{List.first(args)} mix test"])

    System.cmd(
      "bash",
      [
        "-c",
        "aglio -i doc/api/documentation.md -o doc/api/documentation.html"
      ]
    )
  end
end
