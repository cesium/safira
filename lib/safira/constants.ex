defmodule Safira.Constants do
  @moduledoc """
  Constant key value pairs used in the Safira application.
  """

  use Safira.Context

  alias Safira.Constants.Pair

  @doc """
  Get a value by key.

  ## Examples

      iex> get("key")
      {:ok, "value"}

      iex> get("unknown")
      {:error, "key not found"}
  """
  def get(key) do
    fetch_key_value(key)
  end

  defp fetch_key_value(key) do
    case Safira.Standalone.get!(key) do
      nil ->
        get_from_db(key)

      value ->
        {:ok, value}
    end
  end

  @doc """
  Get a value by key from the database.

  ## Examples

      iex> get_from_db("key")
      {:ok, "value"}

      iex> get_from_db("unknown")
      {:error, "key not found"}
  """
  defp get_from_db(key) do
    case Repo.get_by(Pair, key: key) do
      nil ->
        {:error, "key not found"}

      pair ->
        {:ok, Map.get(pair.value, key)}
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
    Safira.Standalone.put(key, value)

    %Pair{}
    |> Pair.changeset(%{key: key, value: %{key => value}})
    |> Repo.insert()
  end

  defp update_key_value_pair(pair, key, value) do
    Safira.Standalone.put(key, value)

    pair
    |> Pair.changeset(%{value: Map.put(pair.value, key, value)})
    |> Repo.update()
  end
end
