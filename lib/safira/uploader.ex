defmodule Safira.Uploader do
  @moduledoc """
  Base uploader module.
  """
  defmacro __using__(_) do
    quote do
      use Waffle.Definition
      use Waffle.Ecto.Definition
    end
  end
end
