defmodule Safira.Spotlights do
  @moduledoc """
  The `Spotlights` module provides functions for managing spotlights.
  """

  use Safira.Context
  alias Safira.Constants
  alias Safira.Spotlights.Spotlight

  @pubsub Safira.PubSub

  def create_spotlight(company_id) do
    now = DateTime.utc_now()
    duration = get_spotlight_duration()

    if duration > 0 do
      end_time = DateTime.add(now, duration, :minute)

      %Spotlight{}
      |> Spotlight.changeset(%{company_id: company_id, end: end_time})
      |> Repo.insert()
      |> case do
        {:ok, spotlight} ->
          broadcast_new_spotlight(spotlight.id)
          {:ok, spotlight}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error, "invalid duration"}
    end
  end

  def get_current_spotlight do
    now = DateTime.utc_now()

    Spotlight
    |> where([s], s.end > ^now)
    |> order_by([s], asc: s.end)
    |> limit(1)
    |> preload(:company)
    |> Repo.one()
  end

  def change_spotlight_duration(time) do
    Constants.set("spotlight_duration", time)
  end

  def get_spotlight_duration do
    case Constants.get("spotlight_duration") do
      {:ok, duration} ->
        duration

      {:error, _} ->
        change_spotlight_duration(0)
        0
    end
  end

  @doc """
  Returns the list of spotlights.

  ## Examples

      iex> list_spotlights()
      [%Spotlight{}, ...]

  """
  def list_spotlights do
    Repo.all(Spotlight)
  end

  @doc """
  Gets a single spotlight.

  Raises `Ecto.NoResultsError` if the Spotlight does not exist.

  ## Examples

      iex> get_spotlight!(123)
      %Spotlight{}

      iex> get_spotlight!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spotlight!(id) do
    Spotlight
    |> preload([:company])
    |> Repo.get!(id)
  end

  @doc """
  Updates a spotlight.

  ## Examples

      iex> update_spotlight(spotlight, %{field: new_value})
      {:ok, %Spotlight{}}

      iex> update_spotlight(spotlight, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spotlight(%Spotlight{} = spotlight, attrs) do
    spotlight
    |> Spotlight.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a spotlight.

  ## Examples

      iex> delete_spotlight(spotlight)
      {:ok, %Spotlight{}}

      iex> delete_spotlight(spotlight)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spotlight(%Spotlight{} = spotlight) do
    Repo.delete(spotlight)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spotlight changes.

  ## Examples

      iex> change_spotlight(spotlight)
      %Ecto.Changeset{data: %Spotlight{}}

  """
  def change_spotlight(%Spotlight{} = spotlight, attrs \\ %{}) do
    Spotlight.changeset(spotlight, attrs)
  end

  def subscribe_to_spotlight_event do
    Phoenix.PubSub.subscribe(@pubsub, "spotlight")
  end

  defp broadcast_new_spotlight(spotlight_id) do
    spotlight = get_spotlight!(spotlight_id)
    Phoenix.PubSub.broadcast(@pubsub, "spotlight", spotlight)
  end
end
