defmodule Safira.CV do
  @moduledoc """
    Upload for cv
    """
  use Arc.Definition

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

  def validate({file, _}) do
    ~w(.pdf) |> Enum.member?(Path.extname(file.file_name))
  end

  def filename(version, _) do
    version
  end

  def storage_dir(version, {file, scope}) do
    struct = scope.__struct__
    |> Kernel.to_string()
    |> String.split(".")
    |> List.last()
    |> String.downcase()

    "uploads/#{struct}/cvs/#{scope.id}"
  end

  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end

end
