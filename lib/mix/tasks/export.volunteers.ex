defmodule Mix.Tasks.Export.Volunteers do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("uuid,name,email,volunteer,food,housing")

    Enum.each(
      Safira.Accounts.list_active_volunteers_attendees(),
      fn a ->
        IO.puts(csv_io(a, food(a.badges), housing(a.badges)))
      end
    )
  end

  defp food(badges) do
    badges
    |> Enum.map(fn b -> b.name end)
    |> Enum.member?("Jantar domingo")
    |> Kernel.not()
  end

  defp housing(badges) do
    bs =
      badges
      |> Enum.map(fn b -> b.name end)

    cond do
      Enum.member?(bs, "Alojamento D. Maria II") ->
        "Alojamento D. Maria II"

      Enum.member?(bs, "Alojamento Alberto Sampaio") ->
        "Alojamento Alberto Sampaio"

      true ->
        "Não tem"
    end
  end

  defp csv_io(attendee, food, housing) do
    "#{attendee.id},#{attendee.name},#{Safira.Accounts.get_user!(attendee.user_id).email},#{
      attendee.volunteer
    },#{food},#{housing}"
  end
end
