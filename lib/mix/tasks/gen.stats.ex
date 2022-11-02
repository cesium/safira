defmodule Mix.Tasks.Gen.Stats do
  @moduledoc """
  Task to generate redeem stats
  """
  use Mix.Task

  alias Safira.Contest

  def run(args) do
    if length(args) != 0 do
      Mix.shell().info("No arguments needed")
    else
      create()
    end
  end

  defp create do
    Mix.Task.run("app.start")

    Contest.list_redeems_stats()
    |> Enum.map(&Poison.encode!/1)
    |> IO.puts()
  end
end
