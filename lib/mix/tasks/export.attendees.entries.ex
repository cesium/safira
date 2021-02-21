defmodule Mix.Tasks.Export.Attendees.Entries do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("uuid,name,email,entries")
    file = File.open!("exported_attendees_entries.csv", [:write, :utf8])
    IO.write(file, "uuid,name,email,entries\n")

    Enum.each(
      Safira.Accounts.list_active_attendees(),
      fn a ->
        IO.puts(csv_io(a))
        IO.write(file, csv_io(a))
        IO.write(file, "\n")
      end
    )
  end

  defp csv_io(attendee) do
    "#{attendee.id},#{attendee.name},#{Safira.Accounts.get_user!(attendee.user_id).email},#{
      attendee.entries
    }"
  end
end
