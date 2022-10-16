defmodule Mix.Tasks.Get.Winner do
  @moduledoc """
  Task to get the winner of the contest
  """
  use Mix.Task

  alias Safira.Contest

  def run(args) do
    cond do
      not Enum.empty?(args) ->
        Mix.shell().info("No arguments needed")

      true ->
        create()
    end
  end

  defp create do
    Mix.Task.run("app.start")

    Contest.get_winner()
    |> Enum.map(&IO.puts/1)
  end
end
