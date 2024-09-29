defmodule Safira.Schema do
  @moduledoc """
  Base schema module.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      import Ecto.Changeset

      alias Safira.Uploaders

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
