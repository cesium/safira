defmodule Safira.Contest do
  @moduledoc """
  The Contest context.
  """
  use Safira.Context

  alias Ecto.Multi
  alias Safira.Accounts.Attendee
  alias Safira.Contest.{Badge, BadgeCategory, BadgeCondition, BadgeRedeem, DailyTokens}

  @pubsub Safira.PubSub

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id) do
    Badge
    |> preload(:category)
    |> Repo.get!(id)
  end

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
  Lists all badges belonging to an attendee.

  ## Examples

      iex> list_attendee_badges(123)
      [%Badge{}, %Badge{}]

  """
  def list_attendee_badges(attendee_id) do
    Badge
    |> join(:inner, [b], br in BadgeRedeem, on: b.id == br.badge_id)
    |> where([b, br], br.attendee_id == ^attendee_id)
    |> select([b], b)
    |> Repo.all()
  end

  @doc """
  Lists all badge redeems belonging to an attendee.

  ## Examples

      iex> list_attendee_redeems(123)
      [%BadgeRedeem{}, %BadgeRedeem{}]

  """
  def list_attendee_redeems(attendee_id) do
    BadgeRedeem
    |> where([br], br.attendee_id == ^attendee_id)
    |> preload([:badge])
    |> Repo.all()
  end

  @doc """
  Lists all badge redeems belonging to a badge.

  ## Examples

      iex> list_badge_redeems(123)
      [%BadgeRedeem{}, %BadgeRedeem{}]

  """
  def list_badge_redeems(badge_id, opts \\ []) do
    BadgeRedeem
    |> where([br], br.badge_id == ^badge_id)
    |> preload(attendee: [:user])
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Counts the number of badge redeems for a badge.

  ## Examples

      iex> count_badge_redeems(123)
      5
  """
  def count_badge_redeems(badge_id) do
    BadgeRedeem
    |> where([br], br.badge_id == ^badge_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Lists all badges with their respective redeem status associated with an attendee odered by redeemed date.

  ## Examples

      iex> list_attendee_all_badges_redeem_status(123)
      [%Badge{}, %Badge{}]
  """
  def list_attendee_all_badges_redeem_status(attendee_id, only_owned \\ false) do
    all_badges = Repo.all(from b in Badge, preload: [:category])

    redeems =
      BadgeRedeem
      |> where([br], br.attendee_id == ^attendee_id)
      |> select([br], {br.badge_id, br.inserted_at})
      |> Repo.all()
      |> Map.new()

    Enum.map(all_badges, fn badge ->
      Map.put(badge, :redeemed_at, Map.get(redeems, badge.id, nil))
    end)
    |> Enum.sort(&(&1.redeemed_at > &2.redeemed_at))
    |> Enum.filter(fn badge ->
      !only_owned or badge.redeemed_at != nil
    end)
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
  Checks if an attendee owns a badge.

  ## Examples

      iex> attendee_owns_badge?(123, 456)
      true

  """
  def attendee_owns_badge?(attendee_id, badge_id) do
    BadgeRedeem
    |> where([br], br.attendee_id == ^attendee_id and br.badge_id == ^badge_id)
    |> Repo.one()
    |> is_nil()
    |> Kernel.not()
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
  Gets the attendee token balance.

  ## Examples

      iex> get_attendee_tokens(attendee)
      100
  """
  def get_attendee_tokens(attendee) do
    Repo.one(from a in Attendee, where: a.id == ^attendee.id, select: a.tokens)
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
  def get_badge_redeem!(id, opts \\ []) do
    BadgeRedeem
    |> apply_filters(opts)
    |> Repo.get!(id)
  end

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
  Redeems a badge for an attendee and broadcasts the action.

  ## Examples

      iex> redeem_badge(badge, attendee, staff)
      {:ok, %Attendee{}}

  """
  def redeem_badge(badge, attendee, staff \\ nil) do
    result =
      redeem_badge_transaction(badge, attendee, staff)
      # Run the transaction
      |> Repo.transaction()

    case result do
      {:ok, %{redeem: redeem}} ->
        broadcast_attendee_redeems_update(redeem.id)
        {:ok, redeem}

      {:error, _} ->
        {:error, "failed to redeem badge"}
    end
  end

  @doc """
  Transaction for a badge redeem.

  ## Examples

      iex> redeem_badge_transaction(badge, attendee, staff)
      %Ecto.Multi{}

  """
  def redeem_badge_transaction(badge, attendee, staff \\ nil) do
    Multi.new()
    # Insert the badge redeem
    |> Multi.insert(
      :redeem,
      BadgeRedeem.changeset(%BadgeRedeem{}, %{
        badge_id: badge.id,
        attendee_id: attendee.id,
        redeemed_by_id: if(staff, do: staff.id, else: nil)
      })
    )
    # Update the attendee token balance (including daily tokens)
    |> Multi.merge(fn %{redeem: _redeem} ->
      change_attendee_tokens_transaction(
        attendee,
        attendee.tokens + badge.tokens,
        :redeem_attendee_update_tokens,
        :redeem_daily_tokens_fetch,
        :redeem_daily_tokens_update
      )
    end)
    # Update final draw entries
    |> Multi.update(
      :attendee_update_entries,
      Attendee.changeset(attendee, %{entries: attendee.entries + badge.entries})
    )
  end

  @doc """
  Subscribes the caller to the specific attendee's badge redeems updates.

  ## Examples

      iex> subscribe_to_attendee_redeems_update(attendee_id)
      :ok
  """
  def subscribe_to_attendee_redeems_update(attendee_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(attendee_id))
  end

  defp topic(attendee_id), do: "attendee:redeems:#{attendee_id}"

  defp broadcast_attendee_redeems_update(redeem_id) do
    redeem = get_badge_redeem!(redeem_id)

    Phoenix.PubSub.broadcast(
      @pubsub,
      topic(redeem.attendee_id),
      Map.put(redeem, :badge, get_badge!(redeem.badge_id))
    )
  end
end
