defmodule Safira.Uploaders.Company do
  @moduledoc """
  Company image uploader.
  """
  use Safira.Uploader

  alias Safira.Companies.Company

  @versions [:original]
  @extension_whitelist ~w(.svg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Company{} = company}) do
    "uploads/companies/company/#{company.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
