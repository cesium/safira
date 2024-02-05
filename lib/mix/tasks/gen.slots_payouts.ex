defmodule Mix.Tasks.Gen.Payouts do
  @shortdoc "Generates slot machine payouts from a CSV"
  @moduledoc """
  This CSV is waiting for:
    probability,multiplier
  """
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  def run(args) do
    if Enum.empty?(args) do
      Mix.shell().info("Needs to receive a file URL.")
    else
      args |> List.first() |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_csv()
    |> validate_probabilities()
    |> insert_payouts()
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [probability, muliplier] ->
      %{
        probability: String.to_float(probability),
        multiplier: String.to_float(muliplier)
      }
    end)
  end

  defp validate_probabilities(list) do
    list
    |> Enum.map_reduce(0, fn payout, acc -> {payout, payout.probability + acc} end)
    |> case do
      {_, x} ->
        if x < 1 do
          list
        else
          raise "The sum of all payout probabilities is bigger 1."
        end
    end
  end

  defp insert_payouts(list) do
    list
    |> Enum.map(fn payout ->
      Safira.Slots.create_payout(payout)
    end)
  end
end
