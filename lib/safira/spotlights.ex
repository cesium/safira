defmodule Safira.Spotlights do
  use Safira.Context

  alias Safira.Spotlights.Spotlight
  alias Safira.Constants

  def get_current_spotlight do
    now = DateTime.utc_now()

    Spotlight
    |> where([s], s.end > ^now)
    |> order_by(asc: :end)
    |> limit(1)
    |> preload(:company)
    |> Repo.one()
  end

  def change_duration_spotlight(time) do
    Constants.set("duration_spotlights", time)
  end

  def get_spotlights_duration do
    case Constants.get("duration_spotlights") do
      {:ok, duration} ->
        duration

      {:error, _} ->
        change_duration_spotlight(0)
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
  def get_spotlight!(id), do: Repo.get!(Spotlight, id)

  @doc """
  Creates a spotlight.

  ## Examples

      iex> create_spotlight(%{field: value})
      {:ok, %Spotlight{}}

      iex> create_spotlight(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spotlight(attrs \\ %{}) do
    %Spotlight{}
    |> Spotlight.changeset(attrs)
    |> Repo.insert()
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
end
