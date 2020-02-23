defmodule Safira.Admin.Contest do
  @moduledoc """
  The Admin.Contest context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Safira.Contest.Badge
  alias Safira.Contest.Redeem
  alias Safira.Contest.Referral

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of badges using filtrex
  filters.

  ## Examples

      iex> list_badges(%{})
      %{badges: [%Badge{}], ...}
  """
  @spec paginate_badges(map) :: {:ok, map} | {:error, any}
  def paginate_badges(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:badges), params["badge"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_badges(filter, params) do
      {:ok,
       %{
         badges: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_badges(filter, params) do
    Badge
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, ...]

  """
  def list_badges do
    Repo.all(Badge)
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id), do: Repo.get!(Badge, id)

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
    |> Badge.admin_changeset(attrs)
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
    |> Badge.admin_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{source: %Badge{}}

  """
  def change_badge(%Badge{} = badge) do
    Badge.admin_changeset(badge, %{})
  end

  @doc """
  Paginate the list of redeems using filtrex
  filters.

  ## Examples

      iex> list_redeems(%{})
      %{redeems: [%Redeem{}], ...}
  """
  @spec paginate_redeems(map) :: {:ok, map} | {:error, any}
  def paginate_redeems(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:redeems), params["redeem"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_redeems(filter, params) do
      {:ok,
       %{
         redeems: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_redeems(filter, params) do
    Redeem
    |> Filtrex.query(filter)
    |> preload([:badge, manager: :user, attendee: :user])
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of redeems.

  ## Examples

      iex> list_redeems()
      [%Redeem{}, ...]

  """
  def list_redeems do
    Repo.all(Redeem)
  end

  @doc """
  Gets a single redeem.

  Raises `Ecto.NoResultsError` if the Redeem does not exist.

  ## Examples

      iex> get_redeem!(123)
      %Redeem{}

      iex> get_redeem!(456)
      ** (Ecto.NoResultsError)

  """
  def get_redeem!(id) do
    Repo.get!(Redeem, id)
    |> Repo.preload([:badge, manager: :user, attendee: :user])
  end

  @doc """
  Creates a redeem.

  ## Examples

      iex> create_redeem(%{field: value})
      {:ok, %Redeem{}}

      iex> create_redeem(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_redeem(attrs \\ %{}) do
    %Redeem{}
    |> Redeem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a redeem.

  ## Examples

      iex> update_redeem(redeem, %{field: new_value})
      {:ok, %Redeem{}}

      iex> update_redeem(redeem, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_redeem(%Redeem{} = redeem, attrs) do
    redeem
    |> Redeem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Redeem.

  ## Examples

      iex> delete_redeem(redeem)
      {:ok, %Redeem{}}

      iex> delete_redeem(redeem)
      {:error, %Ecto.Changeset{}}

  """
  def delete_redeem(%Redeem{} = redeem) do
    Repo.delete(redeem)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking redeem changes.

  ## Examples

      iex> change_redeem(redeem)
      %Ecto.Changeset{source: %Redeem{}}

  """
  def change_redeem(%Redeem{} = redeem) do
    Redeem.changeset(redeem, %{})
  end

  @doc """
  Paginate the list of referrals using filtrex
  filters.

  ## Examples

      iex> list_referrals(%{})
      %{referrals: [%Referral{}], ...}
  """
  @spec paginate_referrals(map) :: {:ok, map} | {:error, any}
  def paginate_referrals(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:referrals), params["referral"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_referrals(filter, params) do
      {:ok,
        %{
          referrals: page.entries,
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_referrals(filter, params) do
    Referral
    |> Filtrex.query(filter)
    |> preload([:badge, attendee: :user])
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of referrals.

  ## Examples

      iex> list_referrals()
      [%Referral{}, ...]

  """
  def list_referrals do
    Repo.all(Referral)
  end

  @doc """
  Gets a single referral.

  Raises `Ecto.NoResultsError` if the Referral does not exist.

  ## Examples

      iex> get_referral!(123)
      %Referral{}

      iex> get_referral!(456)
      ** (Ecto.NoResultsError)

  """
  def get_referral!(id) do 
    Repo.get!(Referral, id)
    |> Repo.preload([:badge, attendee: :user])
  end

  @doc """
  Creates a referral.

  ## Examples

      iex> create_referral(%{field: value})
      {:ok, %Referral{}}

      iex> create_referral(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_referral(attrs \\ %{}) do
    %Referral{}
    |> Referral.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a referral.

  ## Examples

      iex> update_referral(referral, %{field: new_value})
      {:ok, %Referral{}}

      iex> update_referral(referral, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_referral(%Referral{} = referral, attrs) do
    referral
    |> Referral.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Referral.

  ## Examples

      iex> delete_referral(referral)
      {:ok, %Referral{}}

      iex> delete_referral(referral)
      {:error, %Ecto.Changeset{}}

  """
  def delete_referral(%Referral{} = referral) do
    Repo.delete(referral)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking referral changes.

  ## Examples

      iex> change_referral(referral)
      %Ecto.Changeset{source: %Referral{}}

  """
  def change_referral(%Referral{} = referral) do
    Referral.changeset(referral, %{})
  end

  defp filter_config(:badges) do
    defconfig do
      date(:begin)
      date(:end)
      text(:name)
      text(:description)
      number(:type)
    end
  end

  defp filter_config(:redeems) do
    defconfig do
      number(:manager_id)
      number(:badge_id)
    end
  end

  defp filter_config(:referrals) do
    defconfig do
      boolean :available
    end
  end
end
