defmodule Safira.Constants do
  @moduledoc """
  Constant key value pairs used in the Safira application.
  """

  use Safira.Context

  alias Safira.Constants.Pair

  @cache_service :safira_cache

  @doc """
  Get a value by key.

  ## Examples

      iex> get("key")
      {:ok, "value"}

      iex> get("unknown")
      {:error, "key not found"}
  """
  def get(key) do
    # Try to get the value from the cache
    case Cachex.get(@cache_service, key) do
      {:ok, nil} -> fetch_key_value(key)
      {:ok, value} -> {:ok, value}
    end
  end

  defp fetch_key_value(key) do
    case Repo.get_by(Pair, key: key) do
      nil ->
        {:error, "key not found"}

      pair ->
        # Cache the value
        Cachex.put(@cache_service, key, pair.value[key])
        {:ok, pair.value[key]}
    end
  end

  @doc """
  Sets a value by key.

  ## Examples

      iex> set("key", "value")
      :ok
  """
  def set(key, value) do
    case set_key_value(key, value) do
      {:ok, result} ->
        Cachex.put(@cache_service, key, value)
        {:ok, result}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp set_key_value(key, value) do
    case Repo.get_by(Pair, key: key) do
      nil ->
        create_key_value_pair(key, value)

      pair ->
        update_key_value_pair(pair, key, value)
    end
  end

  defp create_key_value_pair(key, value) do
    %Pair{}
    |> Pair.changeset(%{key: key, value: %{key => value}})
    |> Repo.insert()
  end

  defp update_key_value_pair(pair, key, value) do
    pair
    |> Pair.changeset(%{value: Map.put(pair.value, key, value)})
    |> Repo.update()
  end
end
