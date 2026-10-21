defmodule Safira.Uploaders.ScratchCardSymbols do
  @moduledoc """
  ScratchCard symbols image uploader.
  """
  use Safira.Uploader

  alias Safira.Minigames.ScratchCardSymbol

  @versions [:original]
  @extension_whitelist ~w(.svg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %ScratchCardSymbol{} = scratch_card_symbol}) do
    "uploads/minigames/scratch_card/symbols/#{scratch_card_symbol.id}"
  end

  def storage_dir(_, {_file, nil}) do
    "uploads/minigames/scratch_card/symbols/"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
