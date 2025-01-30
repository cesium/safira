defmodule Safira.Uploaders.Member do
  @moduledoc """
  Member image uploader.
  """
  use Safira.Uploader

  alias Safira.Teams.TeamMember

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %TeamMember{} = team_member}) do
    "uploads/team/members/#{team_member.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
