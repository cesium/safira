defmodule Safira.Cv do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  def __storage do
    if Mix.env() == :dev do
      Arc.Storage.Local
    else
      Arc.Storage.S3
    end
  end

  @versions [:original]
  @acl :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    file.file_name |> Path.extname() |> String.downcase() == ".pdf"
  end

  # Override the persisted filenames:
  def filename(_, {_, scope}) do
    "cv-#{scope.name}-#{scope.id}"
  end

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    IO.puts(file)
    IO.puts(scope)
    IO.puts(version)

    struct =
      scope.__struct__
      |> IO.inspect()
      |> Kernel.to_string()
      |> String.split(".")
      |> List.last()
      |> String.downcase()

    "uploads/#{struct}/cvs/#{scope.id}"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_, _) do
    [content_type: MIME.type("pdf")]
  end
end
