defmodule Safira.Uploaders.Spotlight do
  @moduledoc """
  Spotlight image uploader.
  """
  use Safira.Uploader

  alias Safira.Contest.Spotlight

  @versions [:original]
  @extension_whitelist ~w(.svg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Spotlight{} = spotlight}) do
    "uploads/contest/spotlights/#{spotlight.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
