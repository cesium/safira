defmodule Mix.Tasks.Gen.Redeemables do
  @shortdoc "Generates the event Redeemables from a CSV"

  @moduledoc """
  This CSV is waiting for:
    name,price,stock,max_per_user,description,is_redeemable,path_to_image
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
          img: get_avatar(path_to_image)
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
