defmodule Mix.Tasks.Gen.Badges do
  use Mix.Task
  import Mix.Ecto

  NimbleCSV.define(MyParser, separator: ";", escape: "\"")

  #Its waiting for an header or an empty line on the beggining of the file
  # format Coffee break;badge do lanche;2019-02-11;2019-02-12;/tmp/goraster.png

  def run(args) do
    cond do
      length(args) == 0 ->
        Mix.shell.info "Needs to receive atleast one file path ."
      true ->
        args |> create
    end

  end

  defp create(paths) do
    Mix.Task.run "app.start"
    paths
    |> Enum.map(&(parse_csv/1))
    |> Enum.map(&(Safira.Contest.create_badges/1))
    |> Enum.map(
      fn x ->
        case Safira.Repo.transaction(x) do
          {:ok, result} -> IO.inspect(result)
          {:error, error} -> IO.puts(error)
        end
      end)
  end

  defp parse_csv(path) do
    path
    |> File.stream!
    |> MyParser.parse_stream
    |> Stream.map(
      fn [name, description, begin_time, end_time, image_path] ->
        {:ok, begin_datetime, _} = DateTime.from_iso8601("#{begin_time}T00:00:00Z")
        {:ok, end_datetime, _} = DateTime.from_iso8601("#{end_time}T00:00:00Z")

        %{create: %{
            name: name,
            description: description,
            begin: begin_datetime,
            end: end_datetime,
          },
          update: %{
            avatar: %Plug.Upload{
              filename: check_image_filename(image_path), 
              path: check_image_path(image_path)
            }
          }
        }
      end)
  end

  defp check_image_filename(image_path) do
    if is_nil(image_path) do
      "badge-missing.png"
    else
      String.split(image_path, "/") |> List.last
    end
  end

  defp check_image_path(image_path) do
    if is_nil(image_path) do
      "#{File.cwd!}/images/default/badge-missing.png"
    else
      image_path
    end
  end
end
