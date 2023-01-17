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
  @max_file_size 8_000_000

  def validate({file, _}) do

    size = file_size(file)

    valid = file.file_name |> Path.extname() |> String.downcase() |> check_file_size(size)
    if valid do
      Enum.member?(~w(.pdf), file.file_name)
    else
      valid
    end
  end

  defp check_file_size(_, size) do
    size <= @max_file_size
  end

  defp file_size(file) do
    File.stat!(file.path)
    |> Map.get(:size)
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
