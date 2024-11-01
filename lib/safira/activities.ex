defmodule Safira.Activities do
  @moduledoc """
  The Activities context.
  """

  use Safira.Context

  alias Safira.Activities.Activity

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities do
    Repo.all(Activity)
  end

  def list_activities(opts) when is_list(opts) do
    Activity
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_activities(params) do
    Activity
    |> Flop.validate_and_run(params, for: Activity)
  end

  def list_activities(%{} = params, opts) when is_list(opts) do
    Activity
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Activity)
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id), do: Repo.get!(Activity, id)

  @doc """
  Creates a activity.

  ## Examples

      iex> create_activity(%{field: value})
      {:ok, %Activity{}}

      iex> create_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity.

  ## Examples

      iex> update_activity(activity, %{field: new_value})
      {:ok, %Activity{}}

      iex> update_activity(activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity.

  ## Examples

      iex> delete_activity(activity)
      {:ok, %Activity{}}

      iex> delete_activity(activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{data: %Activity{}}

  """
  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end

  alias Safira.Activities.ActivityCategory

  @doc """
  Returns the list of activity_categories.

  ## Examples

      iex> list_activity_categories()
      [%ActivityCategory{}, ...]

  """
  def list_activity_categories do
    Repo.all(ActivityCategory)
  end

  @doc """
  Gets a single activity_category.

  Raises `Ecto.NoResultsError` if the Activity category does not exist.

  ## Examples

      iex> get_activity_category!(123)
      %ActivityCategory{}

      iex> get_activity_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity_category!(id), do: Repo.get!(ActivityCategory, id)

  @doc """
  Creates a activity_category.

  ## Examples

      iex> create_activity_category(%{field: value})
      {:ok, %ActivityCategory{}}

      iex> create_activity_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity_category(attrs \\ %{}) do
    %ActivityCategory{}
    |> ActivityCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity_category.

  ## Examples

      iex> update_activity_category(activity_category, %{field: new_value})
      {:ok, %ActivityCategory{}}

      iex> update_activity_category(activity_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity_category(%ActivityCategory{} = activity_category, attrs) do
    activity_category
    |> ActivityCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity_category.

  ## Examples

      iex> delete_activity_category(activity_category)
      {:ok, %ActivityCategory{}}

      iex> delete_activity_category(activity_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity_category(%ActivityCategory{} = activity_category) do
    Repo.delete(activity_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity_category changes.

  ## Examples

      iex> change_activity_category(activity_category)
      %Ecto.Changeset{data: %ActivityCategory{}}

  """
  def change_activity_category(%ActivityCategory{} = activity_category, attrs \\ %{}) do
    ActivityCategory.changeset(activity_category, attrs)
  end
end
