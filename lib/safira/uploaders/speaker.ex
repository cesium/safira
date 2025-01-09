defmodule Safira.Uploaders.Speaker do
  @moduledoc """
  Speaker image uploader.
  """
  use Safira.Uploader

  alias Safira.Activities.Speaker

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Speaker{} = speaker}) do
    "uploads/activities/speakers/#{speaker.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
