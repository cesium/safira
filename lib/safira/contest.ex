defmodule Safira.Contest do
  @moduledoc """
  The Contest context.
  """
  use Safira.Context

  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.{Badge, BadgeCategory, BadgeCondition, BadgeRedeem, DailyTokens}

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id), do: Repo.get!(Badge, id)

  @doc """
  Lists all badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, %Badge{}]

  """
  def list_badges do
    Badge
    |> Repo.all()
  end

  def list_badges(opts) when is_list(opts) do
    Badge
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_badges(params) do
    Badge
    |> Flop.validate_and_run(params, for: Badge)
  end

  def list_badges(%{} = params, opts) when is_list(opts) do
    Badge
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Badge)
  end

  @doc """
  Lists all badges that can currently be redeemed.

  ## Examples

      iex> list_available_badges()
      [%Badge{}, %Badge{}]

  """
  def list_available_badges do
    Badge
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now())
    |> Repo.all()
  end

  def list_available_badges(opts) when is_list(opts) do
    Badge
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now())
    |> Repo.all()
  end

  def list_available_badges(params) do
    Badge
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now())
    |> Flop.validate_and_run(params, for: Badge)
  end

  def list_available_badges(%{} = params, opts) when is_list(opts) do
    Badge
    |> apply_filters(opts)
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now())
    |> Flop.validate_and_run(params, for: Badge)
  end

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a badge image.

  ## Examples

      iex> update_badge_image(badge, %{image: image})
      {:ok, %Badge{}}

      iex> update_badge_image(badge, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_image(%Badge{} = badge, attrs) do
    badge
    |> Badge.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{data: %Badge{}}

  """
  def change_badge(%Badge{} = badge, attrs \\ %{}) do
    Badge.changeset(badge, attrs)
  end

  @doc """
  Deletes a badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

  """
  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  @doc """
  Gets a single badge category.

  Raises `Ecto.NoResultsError` if the badge category does not exist.

  ## Examples

      iex> get_badge_category!(123)
      %BadgeCategory{}

      iex> get_badge_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_category!(id), do: Repo.get!(BadgeCategory, id)

  @doc """
  Lists all badge categories.

  ## Examples

      iex> list_badge_categories()
      [%BadgeCategory{}, %BadgeCategory{}]

  """
  def list_badge_categories do
    BadgeCategory
    |> Repo.all()
  end

  @doc """
  Creates a badge category.

  ## Examples

      iex> create_badge_category(%{field: value})
      {:ok, %BadgeCategory{}}

      iex> create_badge_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_category(attrs \\ %{}) do
    %BadgeCategory{}
    |> BadgeCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge category.

  ## Examples

      iex> update_badge_category(category, %{field: new_value})
      {:ok, %BadgeCategory{}}

      iex> update_badge_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_category(%BadgeCategory{} = category, attrs) do
    category
    |> BadgeCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge category changes.

  ## Examples

      iex> change_badge_category(category)
      %Ecto.Changeset{data: %BadgeCategory{}}

  """
  def change_badge_category(%BadgeCategory{} = category, attrs \\ %{}) do
    BadgeCategory.changeset(category, attrs)
  end

  @doc """
  Gets a single badge condition.

  Raises `Ecto.NoResultsError` if the badge condition does not exist.

  ## Examples

      iex> get_badge_condition!(123)
      %BadgeCondition{}

      iex> get_badge_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_condition!(id), do: Repo.get!(BadgeCondition, id)

  @doc """
  Lists all badge conditions.

  ## Examples

      iex> list_badge_conditions()
      [%BadgeCondition{}, %BadgeCondition{}]

  """
  def list_badge_conditions do
    BadgeCondition
    |> Repo.all()
  end

  @doc """
  Lists all conditions belonging to a badge.

  ## Examples

      iex> list_badge_conditions(123)
      [%BadgeCondition{}, %BadgeCondition{}]

  """
  def list_badge_conditions(badge_id, opts \\ []) do
    BadgeCondition
    |> where([c], c.badge_id == ^badge_id)
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Creates a badge condition.

  ## Examples

      iex> create_badge_condition(%{field: value})
      {:ok, %BadgeCondition{}}

      iex> create_badge_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_condition(attrs \\ %{}) do
    %BadgeCondition{}
    |> BadgeCondition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge condition.

  ## Examples

      iex> update_badge_condition(condition, %{field: new_value})
      {:ok, %BadgeCondition{}}

      iex> update_badge_condition(condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_condition(%BadgeCondition{} = condition, attrs) do
    condition
    |> BadgeCondition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge condition changes.

  ## Examples

      iex> change_badge_condition(condition)
      %Ecto.Changeset{data: %BadgeCondition{}}

  """
  def change_badge_condition(%BadgeCondition{} = condition, attrs \\ %{}) do
    BadgeCondition.changeset(condition, attrs)
  end

  @doc """
  Deletes a badge condition.

  ## Examples

      iex> delete_condition(condition)
      {:ok, %BadgeCondition{}}

  """
  def delete_condition(%BadgeCondition{} = condition) do
    Repo.delete(condition)
  end

  @doc """
  Changes the attendee token balance and updates the daily tokens.
  """
  def change_attendee_tokens(attendee, tokens) do
    change_attendee_tokens_transaction(attendee, tokens)
    |> Repo.transaction()
  end

  @doc """
  Transaction for updating the attendee token balance and the daily tokens.
  """
  def change_attendee_tokens_transaction(
        attendee,
        tokens,
        attendee_update_tokens_operation_name \\ :attendee_update_tokens,
        daily_tokens_fetch_operation_name \\ :daily_tokens_fetch,
        daily_tokens_update_operation_name \\ :daily_tokens_update
      ) do
    today = Date.utc_today()

    Multi.new()
    |> Multi.update(
      attendee_update_tokens_operation_name,
      Attendee.changeset(attendee, %{tokens: tokens})
    )
    |> Multi.run(daily_tokens_fetch_operation_name, fn repo, _changes ->
      {:ok,
       repo.one(
         from dt in DailyTokens, where: dt.attendee_id == ^attendee.id and dt.date == ^today
       ) || %DailyTokens{date: today, attendee_id: attendee.id}}
    end)
    |> Multi.insert_or_update(daily_tokens_update_operation_name, fn changes ->
      DailyTokens.changeset(Map.get(changes, daily_tokens_fetch_operation_name), %{tokens: tokens})
    end)
  end

  @doc """
  Returns the list of badge_redeems.

  ## Examples

      iex> list_badge_redeems()
      [%BadgeRedeem{}, ...]

  """
  def list_badge_redeems do
    Repo.all(BadgeRedeem)
  end

  @doc """
  Gets a single badge_redeem.

  Raises `Ecto.NoResultsError` if the Badge redeem does not exist.

  ## Examples

      iex> get_badge_redeem!(123)
      %BadgeRedeem{}

      iex> get_badge_redeem!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_redeem!(id), do: Repo.get!(BadgeRedeem, id)

  @doc """
  Creates a badge_redeem.

  ## Examples

      iex> create_badge_redeem(%{field: value})
      {:ok, %BadgeRedeem{}}

      iex> create_badge_redeem(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_redeem(attrs \\ %{}) do
    %BadgeRedeem{}
    |> BadgeRedeem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge_redeem.

  ## Examples

      iex> update_badge_redeem(badge_redeem, %{field: new_value})
      {:ok, %BadgeRedeem{}}

      iex> update_badge_redeem(badge_redeem, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_redeem(%BadgeRedeem{} = badge_redeem, attrs) do
    badge_redeem
    |> BadgeRedeem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a badge_redeem.

  ## Examples

      iex> delete_badge_redeem(badge_redeem)
      {:ok, %BadgeRedeem{}}

      iex> delete_badge_redeem(badge_redeem)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge_redeem(%BadgeRedeem{} = badge_redeem) do
    Repo.delete(badge_redeem)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge_redeem changes.

  ## Examples

      iex> change_badge_redeem(badge_redeem)
      %Ecto.Changeset{data: %BadgeRedeem{}}

  """
  def change_badge_redeem(%BadgeRedeem{} = badge_redeem, attrs \\ %{}) do
    BadgeRedeem.changeset(badge_redeem, attrs)
  end

  @doc """
  Redeems a badge for an attendee.

  ## Examples

      iex> redeem_badge(badge, attendee, staff)
      {:ok, %Attendee{}}

  """
  def redeem_badge(badge, attendee, staff) do
    Multi.new()
    |> Multi.insert(
      :redeem,
      BadgeRedeem.changeset(%BadgeRedeem{}, %{
        badge_id: badge.id,
        attendee_id: attendee.id,
        redeemed_by_id: staff.id
      })
    )
    |> Multi.merge(fn %{redeem: _redeem} ->
      change_attendee_tokens_transaction(attendee, attendee.tokens + badge.tokens)
    end)
  end
end
