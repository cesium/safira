defmodule Mix.Tasks.Gen.Referrals do
  @moduledoc """
  Task to generate referrals
  """
  use Mix.Task
  alias Safira.Contest

  def run(args) do
    cond do
      length(args) != 2 ->
        Mix.shell().info("Needs to receive badge id and number of refarrels")

      args |> List.last() |> String.to_integer() <= 0 ->
        Mix.shell().info("Number of refarrels needs to be above 0.")

      true ->
        args |> Enum.map(&String.to_integer/1) |> create
    end
  end

  defp create([id | number]) do
    Mix.Task.run("app.start")
    IO.puts(Contest.get_badge!(id).name)

    for _n <- 1..List.last(number) do
      Contest.create_referral(%{badge_id: id})
      |> elem(1)
      |> Map.get(:id)
    end
    |> Enum.map(&IO.puts/1)
  end
end
