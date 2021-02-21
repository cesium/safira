defmodule Mix.Tasks.Export.Attendees.Entries do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("uuid,name,email,entries")

    Enum.each(
      Safira.Accounts.list_active_attendees(),
      fn a ->
        IO.puts(csv_io(a))
      end
    )
  end

  defp csv_io(attendee) do
    "#{attendee.id},#{attendee.name},#{Safira.Accounts.get_user!(attendee.user_id).email},#{
      attendee.entries
    }"
  end
end
