defmodule Safira.Activities do
  @moduledoc """
  The Activities context.
  """

  use Safira.Context

  alias Safira.Activities.{Activity, ActivityCategory, Enrolment, Speaker}

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities do
    Activity
    |> preload(:speakers)
    |> Repo.all()
  end

  def list_activities(opts) when is_list(opts) do
    Activity
    |> apply_filters(opts)
    |> preload(:speakers)
    |> Repo.all()
  end

  def list_activities(params) do
    Activity
    |> preload(:speakers)
    |> Flop.validate_and_run(params, for: Activity)
  end

  def list_activities(%{} = params, opts) when is_list(opts) do
    Activity
    |> preload(:speakers)
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Activity)
  end

  @doc """
  Returns the count of activities.

  ## Examples

      iex> get_activities_count()
      42

  """
  def get_activities_count do
    Activity
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the list of daily activities.

  ## Examples

      iex> list_daily_activities(~D[2022-01-01])
      [%Activity{}, ...]

  """
  def list_daily_activities(day) do
    Activity
    |> where([a], a.date == ^day)
    |> order_by([a], a.time_start)
    |> preload([:speakers, :category])
    |> Repo.all()
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
  def get_activity!(id) do
    Activity
    |> preload(:speakers)
    |> Repo.get!(id)
  end

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
  Updates an activity's speakers.

  ## Examples

      iex> upsert_activity_speakers(activity, [1, 2, 3])
      {:ok, %Activity{}}

      iex> upsert_activity_speakers(activity, [1, 2, 3])
      {:error, %Ecto.Changeset{}}

  """
  def upsert_activity_speakers(%Activity{} = activity, speaker_ids) do
    ids = speaker_ids || []

    speakers =
      Speaker
      |> where([s], s.id in ^ids)
      |> Repo.all()

    activity
    |> Activity.changeset_update_speakers(speakers)
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

  @doc """
  Returns the list of speakers.

  ## Examples

      iex> list_speakers()
      [%Speaker{}, ...]

  """
  def list_speakers do
    Repo.all(Speaker)
  end

  def list_speakers(opts) when is_list(opts) do
    Speaker
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_speakers(params) do
    Speaker
    |> Flop.validate_and_run(params, for: Speaker)
  end

  def list_speakers(%{} = params, opts) when is_list(opts) do
    Speaker
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Speaker)
  end

  @doc """
  Returns the list of daily speakers.

  ## Examples
    iex> list_daily_speakers(~D[2022-01-01])
      [%Speaker{}, ...]
  """
  def list_daily_speakers(day) do
    Activity
    |> where([a], a.date == ^day)
    |> order_by([a], asc: a.time_start)
    |> join(:inner, [a], as in "activities_speakers", on: a.id == as.activity_id)
    |> join(:inner, [a, as], s in Speaker, on: as.speaker_id == s.id)
    |> select([a, as, s], %{speaker: s, activity: a})
    |> Repo.all()
  end

  @doc """
  Gets a single speaker.

  Raises `Ecto.NoResultsError` if the Speaker does not exist.

  ## Examples

      iex> get_speaker!(123)
      %Speaker{}

      iex> get_speaker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_speaker!(id), do: Repo.get!(Speaker, id)

  @doc """
  Creates a speaker.

  ## Examples

      iex> create_speaker(%{field: value})
      {:ok, %Speaker{}}

      iex> create_speaker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_speaker(attrs \\ %{}) do
    %Speaker{}
    |> Speaker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a speaker.

  ## Examples

      iex> update_speaker(speaker, %{field: new_value})
      {:ok, %Speaker{}}

      iex> update_speaker(speaker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_speaker(%Speaker{} = speaker, attrs) do
    speaker
    |> Speaker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a speaker picture.

  ## Examples

      iex> update_speaker_picture(speaker, %{picture: image})
      {:ok, %Speaker{}}

      iex> update_speaker_picture(speaker, %{picture: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_speaker_picture(%Speaker{} = speaker, attrs) do
    speaker
    |> Speaker.picture_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a speaker.

  ## Examples

      iex> delete_speaker(speaker)
      {:ok, %Speaker{}}

      iex> delete_speaker(speaker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_speaker(%Speaker{} = speaker) do
    Repo.delete(speaker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking speaker changes.

  ## Examples

      iex> change_speaker(speaker)
      %Ecto.Changeset{data: %Speaker{}}

  """
  def change_speaker(%Speaker{} = speaker, attrs \\ %{}) do
    Speaker.changeset(speaker, attrs)
  end

  @doc """
  Returns the list of highlighted speakers.

  ## Examples

      iex> list_highlighted_speakers()
      [%Speaker{}, ...]

  """
  def list_highlighted_speakers(opts \\ []) do
    Speaker
    |> apply_filters(opts)
    |> where([s], s.highlighted)
    |> Repo.all()
    |> Repo.preload(:activities)
  end

  def enrol(attendee_id, activity_id) do
    Ecto.Multi.new()
    # We need to read the activity before updating the enrolment count to avoid
    # a race condition where the enrolment count changes after the activity was last
    # read from the database, and before this transaction began
    |> Ecto.Multi.one(:activity, Activity |> where([a], a.id == ^activity_id))
    |> Ecto.Multi.insert(
      :enrolment,
      Enrolment.changeset(
        %Enrolment{},
        %{
          attendee_id: attendee_id,
          activity_id: activity_id
        }
      )
    )
    |> Ecto.Multi.update(:new_activity, fn %{activity: act} ->
      Activity.changeset(act, %{enrolment_count: act.enrolment_count + 1})
    end)
    |> Repo.transaction()
  end
end
