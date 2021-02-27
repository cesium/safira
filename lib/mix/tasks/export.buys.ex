defmodule Mix.Tasks.Export.Buys do
  use Mix.Task

  def run(args) do
    Mix.Task.run("app.start")

    cond do
      length(args) == 0 ->
        Mix.shell().info("Output: Screen")
        export()

      true ->
        Mix.shell().info("Output: File (#{args |> List.first()})")
        args |> List.first() |> export
    end
  end

  defp export(path) do
    Enum.each(
      Safira.Accounts.list_active_attendees(),
      fn a ->
        with {:ok, file} = File.open(path, [:append]) do
          IO.binwrite(
            file,
            create_line(
              a,
              print_prizes(Safira.Store.get_attendee_redeemables(a)),
              print_prizes(Safira.Roulette.get_attendee_prizes(a))
            )
          )

          File.close(file)
        end
      end
    )
  end

  defp export() do
    Enum.each(
      Safira.Accounts.list_active_attendees(),
      fn a ->
        Mix.shell().info(
          create_line(
            a,
            Safira.Store.get_attendee_redeemables(a),
            Safira.Roulette.get_attendee_prizes(a)
          )
        )
      end
    )
  end

  defp print_prizes(prizes) do
    prizes
    |> Enum.map(fn p -> "\t#{p.name} -> #{p.quantity}\n" end)
  end

  defp create_line(a, redeemables, roulette_prizes) do
    "#{header(a)}:\n#{print_prizes(redeemables)}#{print_prizes(roulette_prizes)}"
  end

  defp header(attendee) do
    "id : #{attendee.id}, name: #{attendee.name} , email: #{
      Safira.Accounts.get_user!(attendee.user_id).email
    }"
  end
end
