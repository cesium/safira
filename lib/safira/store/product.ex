defmodule Safira.Store.Product do
  @moduledoc """
  Store product.
  """
  use Safira.Schema

  @required_fields ~w(name description price stock max_per_user)a
  @optional_fields ~w(image)a

  @derive {
    Flop.Schema,
    filterable: [:name], sortable: [:name, :price, :stock], default_limit: 11
  }

  schema "products" do
    field :name, :string
    field :description, :string
    field :image, Uploaders.Product.Type
    field :price, :integer
    field :stock, :integer
    field :max_per_user, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_attachments(attrs, [:image])
    |> validate_required(@required_fields)
  end

  def image_changeset(product, attrs) do
    product
    |> cast_attachments(attrs, [:image])
  end
end
