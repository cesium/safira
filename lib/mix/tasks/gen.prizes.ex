defmodule Mix.Tasks.Gen.Prizes do
  @shortdoc "Generates the event Prizes from a CSV"
  @moduledoc """
  This CSV is waiting for:
    name,max_amount_per_attendee,stock,probability,path_to_image
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
    |> sequence()
    |> create_prizes()
    |> insert_prize()
  end

  defp create_prizes({create, update}) do
    {Safira.Roulette.create_prizes(create), update}
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [name, max_amount_per_attendee, stock, probability, is_redeemable, image_path] ->
      {
        %{
          name: name,
          max_amount_per_attendee: String.to_integer(max_amount_per_attendee),
          stock: String.to_integer(stock),
          probability: String.to_float(probability),
          is_redeemable: convert_bool!(is_redeemable)
        },
        %{
          avatar: get_avatar(image_path)
        }
      }
    end)
  end

  defp get_avatar(nil), do: nil

  defp get_avatar(image_path) do
    %Plug.Upload{
      filename: String.split(image_path, "/") |> List.last(),
      path: image_path
    }
  end

  defp validate_probabilities(list) do
    list
    |> Enum.map_reduce(0, fn {prize, _}, acc -> {prize, prize.probability + acc} end)
    |> case do
      {_, 1.0} ->
        list

      _ ->
        raise "The sum of all prizes probabilities is not 1."
    end
  end

  defp sequence(list) do
    create = Enum.map(list, fn value -> elem(value, 0) end)
    update = Enum.map(list, fn value -> elem(value, 1) end)
    {create, update}
  end

  defp insert_prize(transactions) do
    case Safira.Repo.transaction(elem(transactions, 0)) do
      {:ok, result} ->
        Enum.zip(result, elem(transactions, 1))
        |> Enum.map(fn {a, b} ->
          Safira.Roulette.update_prize(elem(a, 1), b)
        end)

      {:error, error} ->
        IO.puts(error)
    end
  end

  defp convert_bool!("yes"), do: true
  defp convert_bool!("no"), do: false
end
