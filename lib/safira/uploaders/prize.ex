defmodule Safira.Uploaders.Prize do
  @moduledoc """
  Prize image uploader.
  """
  use Safira.Uploader

  alias Safira.Minigames.Prize

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png .svg)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Prize{} = prize}) do
    "uploads/prizes/prize/#{prize.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
