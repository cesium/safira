defmodule Safira.SpotlightFactory do
  defmacro __using__(_opts) do
    quote do
      def spotlight_factory do
        %Safira.Interaction.Spotlight{
          active: false,
          badge_id: build(:badge).id,
          lock_version: 1,
        }
      end
    end
  end
end
