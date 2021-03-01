defmodule Mix.Tasks.Export.Buys do
  use Mix.Task

  def run(args) do
    Mix.Task.run("app.start")

    cond do
      length(args) == 0 ->
        Mix.shell().info("Output: Screen")
        export()

      args |> List.first() == "-csv" ->
        Mix.shell().info("Output: CSV")
        export_csv()

      true ->
        Mix.shell().info("Output: File (#{args |> List.first()})")
        args |> List.first() |> export
    end
  end

  defp export() do
    Safira.Accounts.list_active_attendees()
    |> Enum.each(fn attendee ->
      get_attendee_prizes(attendee)
      |> (fn prizes ->
            if length(prizes) > 0 do
              create_line(attendee, prizes)
              |> Mix.shell().info()
            end
          end).()
    end)
  end

  defp export(path) do
    with {:ok, file} = File.open(path, [:append]) do
      Safira.Accounts.list_active_attendees()
      |> Enum.each(fn attendee ->
        get_attendee_prizes(attendee)
        |> (fn prizes ->
              if length(prizes) > 0 do
                create_line(attendee, prizes)
                |> (&IO.binwrite(file, &1 <> "\n")).()
              end
            end).()
      end)

      File.close(file)
    end
  end

  defp export_csv() do
    with {:ok, file} = File.open("prizes - #{ DateTime.utc_now()}.csv", [:append]) do
      Safira.Accounts.list_active_attendees()
      |> Enum.each(fn attendee ->
        header =
          "#{attendee.id}, #{attendee.name}, #{Safira.Accounts.get_user!(attendee.user_id).email}, "

        get_attendee_prizes(attendee)
        |> (fn prizes ->
              prizes
              |> Enum.each(fn prize ->
                IO.binwrite(file, header <> "#{prize.name}, #{prize.quantity}\n")
              end)
            end).()
      end)

      File.close(file)
    end
  end

  defp get_attendee_prizes(attendee) do
    Safira.Roulette.get_attendee_prizes(attendee)
    |> Enum.concat(Safira.Store.get_attendee_redeemables(attendee))
    |> Enum.filter(fn prize ->
      not String.contains?(prize.name, ["Nada", "Entradas", "Lucky Bastard", "Tokens"])
    end)
  end

  defp create_line(attendee, attendee_prizes) do
    "#{header(attendee)}:\n#{print_prizes(attendee_prizes)}"
  end

  defp header(attendee) do
    "name: #{attendee.name} , email: #{Safira.Accounts.get_user!(attendee.user_id).email}"
  end

  defp print_prizes(prizes) do
    prizes
    |> Enum.map(fn p -> "\t#{p.name} -> #{p.quantity}\n" end)
  end
end
