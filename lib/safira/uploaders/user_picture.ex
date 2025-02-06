defmodule Safira.Uploaders.UserPicture do
  @moduledoc """
  User picture image uploader.
  """
  use Safira.Uploader

  alias Safira.Accounts.User

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %User{} = user}) do
    "uploads/user/picture/#{user.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
