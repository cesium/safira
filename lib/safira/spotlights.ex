defmodule Safira.Spotlights do
  @moduledoc """
  The `Spotlights` module provides functions for managing spotlights.
  """

  use Safira.Context

  alias Ecto.Multi
  alias Safira.Companies
  alias Safira.Constants
  alias Safira.Spotlights.Spotlight

  @pubsub Safira.PubSub

  def create_spotlight(company_id) do
    case create_spotlight_transaction(company_id) do
      {:ok, %{spotlight: spotlight}} ->
        broadcast_new_spotlight(spotlight.id)
        {:ok, spotlight}

      {:error, :no_current_spotlight, msg, _details} ->
        {:error, msg}

      {:error, :company_can_create_spotlight, msg, _details} ->
        {:error, msg}

      {:error, reason} ->
        {:error, "Failed to create spotlight: #{inspect(reason)}"}
    end
  end

  defp create_spotlight_transaction(company_id) do
    Multi.new()
    |> Multi.run(:company_can_create_spotlight, fn _repo, _changes ->
      if Companies.can_create_spotlight?(company_id) do
        {:ok, company_id}
      else
        {:error, :company_can_create_spotlight,
         "this company has reached the max spotlights count", %{}}
      end
    end)
    |> Multi.run(:no_current_spotlight, fn _repo, _changes ->
      if get_current_spotlight() do
        {:error, "there is already a spotlight in progress"}
      else
        {:ok, nil}
      end
    end)
    |> Multi.run(:spotlight_end_time, fn _repo, _changes ->
      now = DateTime.utc_now()
      duration = get_spotlight_duration()
      end_time = DateTime.add(now, duration, :minute)
      {:ok, end_time}
    end)
    |> Multi.insert(:spotlight, fn %{spotlight_end_time: end_time} ->
      Spotlight.changeset(%Spotlight{}, %{company_id: company_id, end: end_time})
    end)
    |> Repo.transaction()
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

  def change_spotlight_duration(time) when time > 60 do
    {:error, "duration cannot be greater than 60 minutes"}
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
