defmodule Safira.CV do
  @moduledoc """
  Upload for cv
  """
  use Arc.Definition

  use Arc.Ecto.Definition

  def __storage do
    if Mix.env() == :dev or Mix.env() == :test do
      Arc.Storage.Local
    else
      Arc.Storage.S3
    end
  end

  @versions [:original]
  @acl :public_read
  @max_file_size Application.compile_env!(:safira, :max_cv_file_size)

  def validate({file, _}) do
    size = file_size(file)

    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(~w(.pdf), file_extension) and check_file_size(size) == :ok
  end

  defp check_file_size(size) do
    if size > @max_file_size do
      {:error, "File size is too large"}
    else
      :ok
    end
  end

  defp file_size(file) do
    File.stat!(file.path)
    |> Map.get(:size)
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_version, {_file, scope}) do
    "uploads/user/cvs/" <> "#{scope.id}"
  end

  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end
end
