defmodule Mix.Tasks.Gen.Stats do
  use Mix.Task

  alias Safira.Contest

  def run(args) do
    cond do
      length(args) != 0 ->
        Mix.shell.info "No arguments needed"
      true ->
        create()
    end
  end

  defp create() do
    Mix.Task.run "app.start"

    Contest.list_redeems_stats
    |> Enum.map(&Poison.encode!/1)
    |> IO.puts
  end
end
