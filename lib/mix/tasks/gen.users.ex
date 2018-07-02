defmodule Mix.Tasks.Gen.Users do
  use Mix.Task

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell.info "Needs receive a number greater than 0."
      args |> List.first |> String.to_integer <= 0 ->
        Mix.shell.info "Needs receive a number greater than 0."
      true ->
        args |> List.first |> String.to_integer |> create
    end
  end

  defp create(n) do
    Mix.Task.run "app.start"

    for _n <- 0..n do
      Safira.Repo.insert!(%Safira.Accounts.User{:uuid => UUID.uuid4()})
    end
  end
end
