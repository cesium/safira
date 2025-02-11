defmodule Safira.Contest do
  @moduledoc """
  The Contest context.
  """
  use Safira.Context

  alias Ecto.Multi
  alias Safira.Accounts.{Attendee, User}
  alias Safira.{Companies, Spotlights, Workers}

  alias Safira.Contest.{
    Badge,
    BadgeCategory,
    BadgeCondition,
    BadgeRedeem,
    BadgeTrigger,
    DailyPrize,
    DailyTokens
  }

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
  Lists all users (both attendees and staffs) that have the specified badge and have uploaded their CV.

  ## Examples

      iex> list_users_with_badge_and_cv(123)
      [%User{}, ...]
  """
  def list_users_with_badge_and_cv(badge_id) do
    # First query for attendees with badge and CV
    attendees_query =
      from u in User,
        join: at in Attendee,
        on: at.user_id == u.id,
        join: br in BadgeRedeem,
        on: br.attendee_id == at.id,
        where: br.badge_id == ^badge_id and not is_nil(u.cv),
        where: u.type == :attendee,
        select: u.id

    # Then query for staff with badge and CV
    staff_query =
      from u in User,
        where: u.type == :staff and not is_nil(u.cv),
        select: u.id

    # Combine queries and preload associations after
    User
    |> where([u], u.id in subquery(attendees_query |> union(^staff_query)))
    |> preload([:attendee, :staff])
    |> Repo.all()
  end

  @doc """
  Lists all badge redeems belonging to a badge.

  ## Examples

      iex> list_badge_redeems(123)
      {:ok, {[%BadgeRedeem{}, %BadgeRedeem{}], meta}}

  """
  def list_badge_redeems_meta(badge_id, params \\ %{}, opts \\ []) do
    BadgeRedeem
    |> where([br], br.badge_id == ^badge_id)
    |> join(:inner, [br], a in assoc(br, :attendee), as: :attendee)
    |> join(:inner, [br, a], u in assoc(a, :user), as: :user)
    |> preload(attendee: [:user])
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: BadgeRedeem)
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
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now() and b.givable)
    |> Repo.all()
  end

  def list_available_badges(opts) when is_list(opts) do
    Badge
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now() and b.givable)
    |> Repo.all()
  end

  def list_available_badges(params) do
    Badge
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now() and b.givable)
    |> Flop.validate_and_run(params, for: Badge)
  end

  def list_available_badges(%{} = params, opts) when is_list(opts) do
    Badge
    |> apply_filters(opts)
    |> where([b], b.begin <= ^DateTime.utc_now() and b.end >= ^DateTime.utc_now() and b.givable)
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
    |> Repo.exists?()
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
  Lists all daily prizes

  ## Examples

    iex> list_prizes()
      [%DailyPrize{}, %DailyPrize{}]
  """
  def list_daily_prizes do
    DailyPrize
    |> order_by([dp], asc: fragment("? NULLS FIRST", dp.date), asc: dp.place)
    |> Repo.all()
    |> Repo.preload([:prize])
  end

  @doc """
  Gets a single daily prize.

  Raises `Ecto.NoResultsError` if the daily prize does not exist.

  ## Examples

      iex> get_daily_prize!(123)
      %Badge{}

      iex> get_daily_prize!(456)
      ** (Ecto.NoResultsError)

  """
  def get_daily_prize!(id) do
    Repo.get!(DailyPrize, id)
  end

  defp remove_badge_redeem_from_attendee(badge_id, attendee_id) do
    from(br in BadgeRedeem, where: br.badge_id == ^badge_id and br.attendee_id == ^attendee_id)
    |> Repo.delete_all()
  end

  defp remove_badge_redeem_transaction(badge_id, attendee_id) do
    Multi.new()
    |> Multi.one(:badge ,get_badge!(badge_id))
    |> Multi.one(:attendee ,Accounts.get_attendee!(attendee_id))
    |> Multi.update(
      :remove_badge_from_attendee,
      remove_badgeredeem_from_attendee(badge_id, attendee_id)
    )
    |> Multi.merge(
      fn %{badge: badge, attendee: attendee} ->
        Attendee.update_entries_changeset(attendee, %{entries: max(attendee.entries - badge.entries, 0)})
      end
    )
    |> Multi.merge(fn %{get_badge: badge, get_attendee: attendee} ->
      Contest.change_attendee_tokens_transaction(
        attendee,
        max(attendee.tokens - badge.tokens,0)
      )
    end)
    |> Repo.transaction()
  end

  def remove_badge_from_attendee(badge_id, attendee_id) do
    remove_badge_redeem_transaction(badge_id, attendee_id)
  end

  @doc """
  Creates a daily prize.

  ## Examples

      iex> create_daily_prize(%{field: value})
      {:ok, %DailyPrize{}}

      iex> create_daily_prize(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_daily_prize(attrs \\ %{}) do
    %DailyPrize{}
    |> DailyPrize.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a daily_prize.

  ## Examples

      iex> update_daily_prize(daily_prize, %{field: new_value})
      {:ok, %DailyPrize{}}

      iex> update_daily_prize(daily_prize, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_daily_prize(%DailyPrize{} = daily_prize, attrs \\ %{}) do
    daily_prize
    |> DailyPrize.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking daily prize changes.

  ## Examples

      iex> change_daily_prize()
      %Ecto.Changeset{data: %Badge{}}

  """
  def change_daily_prize(%DailyPrize{} = daily_prize, attrs \\ %{}) do
    DailyPrize.changeset(daily_prize, attrs)
  end

  @doc """
  Deletes a daily prize.

  ## Examples

      iex> delete_daily_prize(daily_prize)
      {:ok, %DailyPrize{}}
  """
  def delete_daily_prize(%DailyPrize{} = daily_prize) do
    Repo.delete(daily_prize)
  end

  @doc """
  Gets the company associated with a badge.

  ## Examples

      iex> get_badge_company(badge)
      %Company{}

  """
  def get_badge_company(badge) do
    Companies.Company
    |> where([c], c.badge_id == ^badge.id)
    |> preload(:tier)
    |> Repo.one()
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
  Gets the top ranking attendees in a given day

  ## Examples

  iex> leaderboard(~D[2025-02-10], 10)
  [%{attendee_id: id, position: 1, name: John Doe, tokens: 10, badges: 20}, ...]

  """
  def leaderboard(day, limit \\ 10) do
    daily_leaderboard_query(day)
    |> limit(^limit)
    |> presentation_query()
    |> Repo.all()
  end

  @doc """
  Gets the position of the given attendee on the daily leaderboard

  ## Examples

  iex> leaderboard_position(~D[2025-02-10], id)
  %{attendee_id: id, position: 1, name: John Doe, tokens: 10, badges: 20}

  """
  def leaderboard_position(day, attendee_id) do
    daily_leaderboard_query(day)
    |> presentation_query()
    |> subquery()
    |> where([u], u.attendee_id == ^attendee_id)
    |> Repo.one()
  end

  defp daily_leaderboard_query(day) do
    daily_leaderboard_tokens_query(day)
    |> join(:inner, [dt], rd in subquery(daily_leaderboard_redeem_query(day)),
      on: dt.attendee_id == rd.attendee_id
    )
    |> sort_query()
  end

  defp daily_leaderboard_redeem_query(day) do
    day_time = DateTime.new!(day, ~T[00:00:00], "Etc/UTC")
    start_time = Timex.beginning_of_day(day_time)
    end_time = Timex.end_of_day(day_time)

    BadgeRedeem
    |> join(:inner, [rd], b in Badge, on: rd.badge_id == b.id)
    |> where([rd], rd.inserted_at >= ^start_time and rd.inserted_at <= ^end_time)
    |> where([rd, b], b.counts_for_day)
    |> group_by([rd], rd.attendee_id)
    |> select([rd], %{redeem_count: count(rd.id), attendee_id: rd.attendee_id})
  end

  defp daily_leaderboard_tokens_query(day) do
    start_time = Timex.beginning_of_day(day)
    end_time = Timex.end_of_day(day)

    DailyTokens
    |> where([dt], dt.date >= ^start_time and dt.date <= ^end_time)
  end

  defp sort_query(query) do
    query
    |> order_by([dt, rd], desc: rd.redeem_count, desc: dt.tokens)
  end

  defp presentation_query(query) do
    query
    |> join(:inner, [dt, rd], at in Safira.Accounts.Attendee, on: at.id == rd.attendee_id)
    |> join(:inner, [dt, rd, at], u in Safira.Accounts.User, on: u.id == at.user_id)
    |> where([dt, rd, at, u], not at.ineligible)
    |> select([dt, rd, at, u], %{
      attendee_id: at.id,
      position:
        fragment("row_number() OVER (ORDER BY ? DESC, ? DESC)", rd.redeem_count, dt.tokens),
      name: u.name,
      handle: u.handle,
      badges: rd.redeem_count,
      tokens: dt.tokens
    })
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
  Gets the count of redeemed badges for an attendee.

  ## Examples

      iex> get_attendee_redeemed_badges_count(attendee, category)
      5
  """
  def get_attendee_redeemed_badges_count(attendee, nil) do
    BadgeRedeem
    |> where([br], br.attendee_id == ^attendee.id)
    |> Repo.aggregate(:count, :id)
  end

  def get_attendee_redeemed_badges_count(attendee, category) do
    BadgeRedeem
    |> where([br], br.attendee_id == ^attendee.id)
    |> join(:inner, [br], b in Badge, on: br.badge_id == b.id)
    |> where([br, b], b.category_id == ^category.id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets the count of badges for a category.

  ## Examples

      iex> get_category_badges_count(category)
      5
  """
  def get_category_badges_count(nil) do
    Repo.aggregate(Badge, :count, :id)
  end

  def get_category_badges_count(category) do
    Badge
    |> where([b], b.category_id == ^category.id)
    |> Repo.aggregate(:count, :id)
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

        # Enqueue job to check conditions
        enqueue_badge_conditions_validation_job(attendee, badge)

        {:ok, redeem}

      {:error, :redeem, _, _} ->
        {:error, "attendee already has this badge"}

      {:error, _, _, _} ->
        {:error, "could not redeem badge"}
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
    # Verify if badge is associated with a company and it is on spotlight (if true multiply tokens).
    |> Multi.run(:badge_tokens, fn _repo, _changes ->
      company = get_badge_company(badge)

      if company && Spotlights.company_on_spotlight?(company.id) do
        # If the the badge being redeemed is on spotlight, trigger the spotlight badge redem event
        enqueue_badge_trigger_execution_job(attendee, :redeem_spotlighted_badge_event)
        {:ok, floor(badge.tokens * company.tier.spotlight_multiplier)}
      else
        {:ok, badge.tokens}
      end
    end)
    # Update the attendee token balance (including daily tokens)
    |> Multi.merge(fn %{redeem: _redeem, badge_tokens: tokens} ->
      change_attendee_tokens_transaction(
        attendee,
        attendee.tokens + tokens,
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

  defp enqueue_badge_conditions_validation_job(attendee, badge) do
    # Enqueue job to check conditions
    Oban.insert(Workers.CheckBadgeConditions.new(%{attendee_id: attendee.id, badge_id: badge.id}))
  end

  @doc """
  Lists all currently valid badge conditions for a category.

  ## Examples

      iex> list_valid_badge_conditions(category)
      [%BadgeCondition{}, %BadgeCondition{}]
  """
  def list_valid_badge_conditions(category) do
    BadgeCondition
    |> where([c], c.category_id == ^category.id or is_nil(c.category_id))
    |> where([c], c.begin <= ^DateTime.utc_now() and c.end >= ^DateTime.utc_now())
    |> preload([:category, :badge])
    |> Repo.all()
  end

  @doc """
  Returns the list of badge_triggers.

  ## Examples

      iex> list_badge_triggers()
      [%BadgeTrigger{}, ...]

  """
  def list_badge_triggers do
    Repo.all(BadgeTrigger)
  end

  @doc """
  Gets a single badge_trigger.

  Raises `Ecto.NoResultsError` if the Badge trigger does not exist.

  ## Examples

      iex> get_badge_trigger!(123)
      %BadgeTrigger{}

      iex> get_badge_trigger!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_trigger!(id), do: Repo.get!(BadgeTrigger, id)

  @doc """
  Creates a badge_trigger.

  ## Examples

      iex> create_badge_trigger(%{field: value})
      {:ok, %BadgeTrigger{}}

      iex> create_badge_trigger(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_trigger(attrs \\ %{}) do
    %BadgeTrigger{}
    |> BadgeTrigger.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge_trigger.

  ## Examples

      iex> update_badge_trigger(badge_trigger, %{field: new_value})
      {:ok, %BadgeTrigger{}}

      iex> update_badge_trigger(badge_trigger, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_trigger(%BadgeTrigger{} = badge_trigger, attrs) do
    badge_trigger
    |> BadgeTrigger.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a badge_trigger.

  ## Examples

      iex> delete_badge_trigger(badge_trigger)
      {:ok, %BadgeTrigger{}}

      iex> delete_badge_trigger(badge_trigger)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge_trigger(%BadgeTrigger{} = badge_trigger) do
    Repo.delete(badge_trigger)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge_trigger changes.

  ## Examples

      iex> change_badge_trigger(badge_trigger)
      %Ecto.Changeset{data: %BadgeTrigger{}}

  """
  def change_badge_trigger(%BadgeTrigger{} = badge_trigger, attrs \\ %{}) do
    BadgeTrigger.changeset(badge_trigger, attrs)
  end

  @doc """
  Lists all triggers belonging to a badge.

  ## Examples

      iex> list_badge_triggers(123)
      [%BadgeTrigger{}, %BadgeTrigger{}]

  """
  def list_badge_triggers(badge_id) do
    BadgeTrigger
    |> where([bt], bt.badge_id == ^badge_id)
    |> Repo.all()
  end

  @doc """
  Lists all triggers belonging to an event.

  ## Examples

      iex> list_event_badge_triggers(:upload_cv_event)
      [%BadgeTrigger{}, %BadgeTrigger{}]

  """
  def list_event_badge_triggers(event) do
    BadgeTrigger
    |> where([bt], bt.event == ^event)
    |> preload(:badge)
    |> Repo.all()
  end

  @doc """
  Enqueues a job to execute the badge triggers for an attendee and a specific event.

  ## Examples

      iex> enqueue_badge_trigger_execution_job(attendee, :upload_cv_event)
      :ok
  """
  def enqueue_badge_trigger_execution_job(attendee, event) do
    Oban.insert(Workers.RunBadgeTriggers.new(%{attendee_id: attendee.id, event: event}))
  end
end
