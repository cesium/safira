defmodule Safira.Avatar do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  def __storage do
    if Mix.env == :dev do
      Arc.Storage.Local
    else
      Arc.Storage.S3
    end
  end

  @versions [:original]
  @acl :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .png .gif) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    struct = scope.__struct__
    |> Kernel.to_string
    |> String.split(".")
    |> List.last
    |> String.downcase
   "uploads/#{struct}/avatars/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, scope) do
    struct = scope.__struct__
    |> Kernel.to_string
    |> String.split(".")
    |> List.last
    |> String.downcase
    "#{System.get_env("URL")}/images/#{struct}-missing.png"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end
end
