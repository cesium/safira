defmodule Mix.Tasks.Get.Winner do
  use Mix.Task

  alias Safira.Contest

  def run(args) do
    cond do
      length(args)!= 0->
        Mix.shell.info "No arguments needed"
      true ->
        create()
    end
  end

  defp create() do
    Mix.Task.run "app.start"
    
    Contest.get_winner()
    |> Enum.map(&(IO.puts/1))
    
  end
end
