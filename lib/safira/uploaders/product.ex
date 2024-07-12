defmodule Safira.Uploaders.Product do
  use Safira.Uploader

  alias Safira.Store.Product

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .svg)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Product{} = product}) do
    "uploads/store/products/#{product.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
