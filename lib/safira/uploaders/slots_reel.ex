defmodule Safira.Uploaders.SlotsReelIcon do
  @moduledoc """
  Slots reel image uploader.
  """
  use Safira.Uploader

  alias Safira.Minigames.SlotsReelIcon

  @versions [:original]
  @extension_whitelist ~w(.svg)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %SlotsReelIcon{} = slots_reel_icon}) do
    "uploads/minigames/slots/reel_icons/#{slots_reel_icon.id}"
  end

  def storage_dir(_, {_file, nil}) do
    "uploads/minigames/slots/reel_icons/"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
