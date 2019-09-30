defmodule Safira.AttendeeFactory do
  defmacro __using__(_opts) do
    quote do
      def attendee_factory do
        %Safira.Accounts.Attendee{
          nickname: "safira_foo",
          volunteer: false
        }
      end
    end
  end
end
