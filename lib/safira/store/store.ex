defmodule Safira.Store do
  @moduledoc """
  The Store context.
  """

  use Safira.Context

  alias Safira.Store.Product

  @doc """
  Returns the list of products.
  """
  def list_products do
    Repo.all(Product)
  end

  def list_products(opts) when is_list(opts) do
    Product
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_products(params) do
    Product
    |> Flop.validate_and_run(params, for: Product)
  end

  def list_products(%{} = params, opts) when is_list(opts) do
    Product
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a product image.

  ## Examples

      iex> update_product_image(product, %{image: image})
      {:ok, %Product{}}

      iex> update_product_image(product, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_product_image(%Product{} = product, attrs) do
    product
    |> Product.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
