defmodule Mix.Tasks.Gen.Prizes do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Generates the event Prizes from a CSV"

  @moduledoc """
  This CSV is waiting for:
    name,max_amount_per_attendee,stock,probability,path_to_image
  """

  def run(args) do
    cond do
      Enum.empty?(args) ->
        Mix.shell().info("Needs to receive a file URL.")

      true ->
        args |> List.first() |> create
    end
  end

  defp create(path) do
    Mix.Task.run("app.start")

    path
    |> parse_csv
    |> validate_probabilities
    |> Enum.map(fn prize -> Safira.Roulette.create_prize(prize) end)
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [name, max_amount_per_attendee, stock, probability, image_path] ->
      %{
        name: name,
        max_amount_per_attendee: String.to_integer(max_amount_per_attendee),
        stock: String.to_integer(stock),
        probability: String.to_float(probability),
        avatar: %Plug.Upload{
          filename: check_image_filename(image_path),
          path: check_image_path(image_path)
        }
      }
    end)
  end

  defp check_image_filename(image_path) do
    if String.trim(image_path) == "" do
      "prize-missing.png"
    else
      String.split(image_path, "/") |> List.last()
    end
  end

  defp check_image_path(image_path) do
    if String.trim(image_path) == "" do
      "#{File.cwd!()}/assets/static/images/prize-missing.png"
    else
      image_path
    end
  end

  defp validate_probabilities(list) do
    list
    |> Enum.map_reduce(0, fn prize, acc -> {prize, prize.probability + acc} end)
    |> case do
      {_, 1.0} ->
        list

      _ ->
        raise "The sum of all prizes probabilities is not 1."
    end
  end
end
