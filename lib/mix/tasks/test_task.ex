defmodule Mix.Tasks.TestTask do
  use Mix.Task

  alias Safira.Repo
  alias Safira.Accounts
  alias Safira.Accounts.User

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell.info "Needs to receive an user email."
      true ->
        args |> List.first |> compare
    end
  end

  defp compare(string) do
    case string do
      "AB" -> IO.puts "primeiro"
      "BA" -> IO.puts "segundo"
       _ -> IO.puts "resto"
    end
  end
end
