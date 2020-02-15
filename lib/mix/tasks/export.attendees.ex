defmodule Mix.Tasks.Export.Attendees do
    use Mix.Task
  
    def run(_) do
      Mix.Task.run "app.start"
      Safira.Accounts.list_active_attendees
      |> Enum.each( fn a -> 
          Mix.shell.info "#{a.id},#{a.name},#{Safira.Accounts.get_user!(a.user_id).email}"
         end)
    end
  end