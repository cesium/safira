defmodule Mix.Tasks.Gen.Redeemables do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Generates the event Redeemables from a CSV"

  @moduledoc """
  This CSV is waiting for:
    name,price,stock,max_per_user,description,is_redeemable,path_to_image
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
    |> sequence()
    |> create_redeemables()
    |> insert_redeemable()
  end

  defp create_redeemables({create, update}) do
    {Safira.Store.create_redeemables(create), update}
  end

  defp parse_csv(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [name, price, stock, max_per_user, description, is_redeemable, path_to_image] ->
      {
        %{
          name: name,
          price: String.to_integer(price),
          stock: String.to_integer(stock),
          max_per_user: String.to_integer(max_per_user),
          description: description,
          is_redeemable: convert_bool!(is_redeemable)
        },
        %{
          img: %Plug.Upload{
            filename: check_image_filename(path_to_image),
            path: check_image_path(path_to_image)
          }
        }
      }
    end)
  end

  defp check_image_filename(image_path) do
    if String.trim(image_path) == "" do
      "redeemable-missing.svg"
    else
      String.split(image_path, "/") |> List.last()
    end
  end

  defp check_image_path(image_path) do
    if String.trim(image_path) == "" do
      "#{File.cwd!()}/assets/static/images/redeemable-missing.svg"
    else
      image_path
    end
  end

  defp sequence(list) do
    create = Enum.map(list, fn value -> elem(value, 0) end)
    update = Enum.map(list, fn value -> elem(value, 1) end)
    {create, update}
  end

  defp insert_redeemable(transactions) do
    case Safira.Repo.transaction(elem(transactions, 0)) do
      {:ok, result} ->
        Enum.zip(result, elem(transactions, 1))
        |> Enum.map(fn {a, b} ->
          Safira.Store.update_redeemable(elem(a, 1), b)
        end)

      {:error, error} ->
        IO.puts(error)
    end
  end

  defp convert_bool!("yes"), do: true
  defp convert_bool!("no"), do: false
end
