defmodule Safira.InteractionFactory do
  @moduledoc """
  A factory to build all interaction related structs
  """

  alias Safira.Interaction.Bonus

  defmacro __using__(_opts) do
    quote do
      def bonus_factory do
        %Bonus{
          count: 1
        }
      end
    end
  end
end
