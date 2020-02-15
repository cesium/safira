defmodule Mix.Tasks.Export.Attendees do
    use Mix.Task
  
    def run(_) do
      Mix.Task.run "app.start"
      attendees = Safira.Accounts.list_active_attendees
      Enum.each(attendees, fn a -> 
        user = Safira.Accounts.get_user!(a.user_id)
        Mix.shell.info "#{a.id},#{a.name},#{user.email}"
      end)
    end
  end