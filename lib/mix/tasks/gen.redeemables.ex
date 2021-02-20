defmodule Mix.Tasks.Gen.Redeemables do
    use Mix.Task

    alias NimbleCSV.RFC4180, as: CSV

    @shortdoc "Generates the event Redeemables from a CSV"

    @moduledoc """
    This CSV is waiting for:
      name,price,stock,max_per_user,description,path_to_image
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
      |> Enum.map(fn redeemable ->
        Safira.Store.create_redeemable(redeemable) end)
    end

    defp parse_csv(path) do
      path
      |> File.stream!()
      |> CSV.parse_stream
      |> Enum.map(fn [name, price, stock, max_per_user, description, path_to_image] ->
        %{
          name: name,
          price: String.to_integer(price),
          stock: String.to_integer(stock),
          max_per_user: String.to_integer(max_per_user),
          description: description,
          img: %Plug.Upload{
            filename: check_image_filename(path_to_image),
            path: check_image_path(path_to_image)
          }
        }
      end)
    end

    defp check_image_filename(image_path) do
      if String.trim(image_path) == "" do
        "redeemable-missing.png"
      else
        String.split(image_path, "/") |> List.last()
      end
    end

    defp check_image_path(image_path) do
      if String.trim(image_path) == "" do
        "#{File.cwd!()}/assets/static/images/redeemable-missing.png"
      else
        image_path
      end
    end
end
