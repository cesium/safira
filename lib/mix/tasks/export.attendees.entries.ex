defmodule Mix.Tasks.Export.Attendees.Entries do
  @moduledoc """
  Task to export the entries for the final draw
  """
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    Mix.shell().info("uuid,name,email,entries")

    Safira.Accounts.list_active_attendees()
    |> Enum.each(fn a -> csv_io(a) |> Mix.shell().info end)
  end

  defp csv_io(attendee) do
    "#{attendee.id},#{attendee.name},#{Safira.Accounts.get_user!(attendee.user_id).email},#{
      attendee.entries
    }"
  end
end
