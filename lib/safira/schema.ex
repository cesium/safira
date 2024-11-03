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

      def validate_url(changeset, field) do
        changeset
        |> validate_format(
          field,
          ~r/^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/,
          message: "must start with http:// or https:// and have a valid domain"
        )
      end
    end
  end
end
