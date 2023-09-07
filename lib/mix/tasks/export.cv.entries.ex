defmodule Mix.Tasks.Export.Cv.Entries do
  @moduledoc """
  Task to export all attendees
  """
  use Mix.Task
  alias Safira.Accounts

  def run(args) do
    Mix.Task.run("app.start")

    if length(args) == 1 do
      file = List.first(args)

      Accounts.list_active_attendees()
      |> Enum.filter(fn at -> at.cv != nil end)
      |> Enum.with_index()
      |> Enum.map(&attendee_row/1)
      |> then(fn list -> ["id,uuid,name,email" | list] end)
      |> Enum.intersperse("\n")
      |> then(fn data -> File.write!(file, data) end)
    else
      Mix.shell().info("Must receive one argument: the path of the file to export the data to")
    end
  end

  defp attendee_row({attendee, id}) do
    "#{id},#{attendee.id},#{attendee.name},#{Safira.Accounts.get_user!(attendee.user_id).email}"
  end
end
