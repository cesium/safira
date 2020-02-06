defmodule Safira.BadgeFactory do
  defmacro __using__(_opts) do
    quote do
      def badge_factory do
        %Safira.Contest.Badge{
          name: "Badge Test",
          description: "Only for Testing",
          type: 2
        }
      end
    end
  end
end
