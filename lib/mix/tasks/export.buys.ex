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
              header(a),
              print_redeemables(Safira.Store.get_attendee_redeemables(a))
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
            header(a),
            print_redeemables(Safira.Store.get_attendee_redeemables(a))
          )
        )
      end
    )
  end

  defp print_redeemables(redeemables) do
    redeemables
    |> Enum.map(fn r -> " (#{r.name}, #{r.quantity})" end)
  end

  defp create_line(header, redeemables) do
    "#{header} ->#{redeemables}\n"
  end

  defp header(attendee) do
    "id : #{attendee.id}, name: #{attendee.name} , email: #{
      Safira.Accounts.get_user!(attendee.user_id).email
    }"
  end
end
