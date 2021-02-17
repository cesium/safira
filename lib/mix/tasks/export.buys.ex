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
        redeemables = Safira.Store.get_attendee_redeemables(a)
        head = "id : #{a.id}, name: #{a.name} , email: #{Safira.Accounts.get_user!(a.user_id).email}"
        attendee_products = print_redeemables(redeemables)
        line = "#{head} ->#{attendee_products}\n"
        with {:ok, file} = File.open(path, [:append]) do
          IO.binwrite(file, line)
          File.close(file)
        end end)
  end

  defp export() do
    Enum.each(
      Safira.Accounts.list_active_attendees(),
      fn a ->
        redeemables = Safira.Store.get_attendee_redeemables(a)
        head = "id : #{a.id}, name: #{a.name} , email: #{Safira.Accounts.get_user!(a.user_id).email}"
        attendee_products = print_redeemables(redeemables)
        line = "#{head} ->#{attendee_products}\n"
        IO.puts line end)
  end
  
  defp print_redeemables(redeemables) do
    products = ""
    redeemables
    |> Enum.map(fn r -> products <> " (#{r.name}, #{r.quantity})" end)
  end
end
