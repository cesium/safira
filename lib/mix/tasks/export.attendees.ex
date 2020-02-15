defmodule Mix.Tasks.Export.Attendees do
    use Mix.Task
  
    def run(_) do
      Mix.Task.run "app.start"
      IO.puts "UUID,Name,Email"
      Safira.Accounts.list_active_attendees
      |> Enum.each( fn a -> 
        IO.puts "#{a.id},#{a.name},#{Safira.Accounts.get_user!(a.user_id).email}"
         end)
    end
  end