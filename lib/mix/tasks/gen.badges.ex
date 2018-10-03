defmodule Mix.Tasks.Gen.Badges do
  use Mix.Task
  import Mix.Ecto

  NimbleCSV.define(MyParser, separator: ";", escape: "\"")

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
          {:ok, result} -> result
          {:error, error} -> IO.puts(error)
        end
      end)
  end

  defp parse_csv(path) do
    path
    |> File.stream!
    |> MyParser.parse_stream
    |> Stream.map(
      fn [name, description,begin_time,end_time,url] ->
        {:ok,begin_datetime,_} = DateTime.from_iso8601("#{begin_time}T00:00:00Z")
        {:ok,end_datetime,_} = DateTime.from_iso8601("#{end_time}T00:00:00Z")

        %{name: name,
          description: description,
          begin: begin_datetime,
          end: end_time,
          avatar: url}
      end)
  end
end
