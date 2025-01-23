defmodule Safira.Uploader do
  @moduledoc """
  Base uploader module.
  """
  defmacro __using__(_) do
    quote do
      use Waffle.Definition
      use Waffle.Ecto.Definition

      def s3_object_headers(_version, {file, _scope}) do
        [content_type: MIME.from_path(file.file_name)]
      end
    end
  end
end
