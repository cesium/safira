defmodule Safira.Store do
  @moduledoc """
  The Store context.
  """

  use Safira.Context

  alias Ecto.Multi

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Inventory
  alias Safira.Inventory.Item
  alias Safira.Store
  alias Safira.Store.Product

  @pubsub Safira.PubSub

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

  def list_purchases(params) do
    Item
    |> join(:left, [i], p in assoc(i, :product), as: :product)
    |> preload(attendee: [:user], product: [])
    |> Flop.validate_and_run(params, for: Item)
  end

  def list_purchases(%{} = params, opts) when is_list(opts) do
    Item
    |> join(:left, [i], p in assoc(i, :product), as: :product)
    |> apply_filters(opts)
    |> preload(attendee: [:user], product: [])
    |> Flop.validate_and_run(params, for: Item)
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

  def refund_transaction(item_id) do
    Multi.new()
    |> Multi.run(:get_item, fn _repo, _changes ->
      item = Inventory.get_item!(item_id)
      {:ok, item}
    end)
    |> Multi.update(:update_product, fn %{get_item: item} ->
      Store.Product.changeset(item.product, %{stock: item.product.stock + 1})
    end)
    |> Multi.delete(:delete_item, fn %{get_item: item} ->
      item
    end)
    |> Multi.merge(fn %{get_item: item} ->
      Contest.change_attendee_tokens_transaction(
        item.attendee,
        item.attendee.tokens + item.product.price
      )
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a product and broadcasts the product change to all subscribed clients.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    case product
         |> Product.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_product} ->
        broadcast_product_update(updated_product.id)
        {:ok, updated_product}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a product image and broadcasts the product change to all subscribed clients.

  ## Examples

      iex> update_product_image(product, %{image: image})
      {:ok, %Product{}}

      iex> update_product_image(product, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_product_image(%Product{} = product, attrs) do
    case product
         |> Product.image_changeset(attrs)
         |> Repo.update() do
      {:ok, updated_product} ->
        broadcast_product_update(updated_product.id)
        {:ok, updated_product}

      {:error, changeset} ->
        {:error, changeset}
    end
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

  defp count_attendee_items_by_product(%Product{} = product, %Attendee{} = attendee) do
    Item
    |> where([i], i.product_id == ^product.id)
    |> where([i], i.attendee_id == ^attendee.id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Checks if an attendee can purchase a product.

  ## Examples

      iex> can_attendee_purchase_product(product, attendee)
      true

      iex> can_attendee_purchase_product(product, attendee)
      false

  """
  def can_attendee_purchase_product(%Product{} = product, %Attendee{} = attendee) do
    product.stock > 0 and
      product.max_per_user > count_attendee_items_by_product(product, attendee) and
      attendee.tokens >= product.price
  end

  @doc """
  Transaction for a product purchase requested by an attendee.

  ## Examples

      iex> purchase_product(product, attendee)
      {:ok, %Item{}}

      iex> purchase_product(product, attendee)
      {:error, %Ecto.Changeset{}}

  """
  def purchase_product(%Product{} = product, %Attendee{} = attendee) do
    result =
      Multi.new()
      |> Multi.run(:can_purchase, fn _repo, _changes ->
        if can_attendee_purchase_product(product, attendee) do
          {:ok, "can purchase"}
        else
          {:error, "can't purchase"}
        end
      end)
      |> Multi.insert(
        :item,
        Item.changeset(%Item{}, %{
          product_id: product.id,
          attendee_id: attendee.id,
          type: :product
        })
      )
      |> Multi.update(:product, Product.changeset(product, %{stock: product.stock - 1}))
      |> Multi.merge(fn _ ->
        Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - product.price)
      end)
      |> Repo.transaction()

    case result do
      {:ok, data} ->
        broadcast_product_update(product.id)
        {:ok, data.item}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Subscribes the caller to the specific product's updates.

  ## Examples

      iex> subscribe_to_product_update(product_id)
      :ok
  """
  def subscribe_to_product_update(product_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(product_id))
  end

  defp topic(product_id), do: "product:#{product_id}"

  defp broadcast_product_update(product_id) do
    product = get_product!(product_id)
    Phoenix.PubSub.broadcast(@pubsub, topic(product_id), product)
  end
end
