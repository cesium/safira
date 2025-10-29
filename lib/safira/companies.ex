defmodule Safira.Companies do
  @moduledoc """
  The Companies context.
  """

  use Safira.Context

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Companies.{Company, Tier}
  alias Safira.Contest
  alias Safira.Spotlights.Spotlight
  alias Safira.Uploaders

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies do
    Company
    |> Repo.all()
  end

  def list_companies(opts) when is_list(opts) do
    Company
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_companies(params) do
    Company
    |> join(:left, [c], t in assoc(c, :tier), as: :tier)
    |> preload(:tier)
    |> Flop.validate_and_run(params, for: Company)
  end

  def list_companies(%{} = params, opts) when is_list(opts) do
    Company
    |> apply_filters(opts)
    |> join(:left, [c], t in assoc(c, :tier), as: :tier)
    |> preload(:tier)
    |> Flop.validate_and_run(params, for: Company)
  end

  @doc """
  Returns the count of companies.

  ## Examples

      iex> get_companies_count()
      42

  """
  def get_companies_count do
    Company
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id) do
    Company
    |> Repo.get_by!(id: id)
    |> Repo.preload([:user])
  end

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def upsert_company_and_user(company \\ %Company{}, attrs \\ %{}) do
    attrs_user = Map.put(attrs["user"], "confirmed_at", DateTime.utc_now())
    company_user = if is_nil(company.user_id), do: %User{}, else: company.user

    case Ecto.Multi.new()
         |> Ecto.Multi.insert_or_update(
           :user,
           User.profile_changeset(company_user, Map.put(attrs_user, "type", "company"))
         )
         |> Ecto.Multi.insert_or_update(:company, fn %{user: user} ->
           Company.changeset(company, Map.put(Map.delete(attrs, "user"), "user_id", user.id))
         end)
         |> Repo.transaction() do
      {:ok, %{user: user, company: company}} ->
        {:ok, %{user: user, company: company}}

      {:error, failed_operation, failed_value, changes_so_far} ->
        {:error, failed_operation, failed_value, changes_so_far}
    end
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a company logo.

  ## Examples

      iex> update_company_logo(company, %{logo: image})
      {:ok, %Company{}}

      iex> update_company_logo(company, %{logo: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_company_logo(%Company{} = company, attrs) do
    company
    |> Company.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  @doc """
  Returns the list of tiers.

  ## Examples

      iex> list_tiers()
      [%Tier{}, ...]

  """
  def list_tiers do
    Tier
    |> order_by(:priority)
    |> Repo.all()
  end

  @doc """
  Gets a single tier.

  Raises `Ecto.NoResultsError` if the Tier does not exist.

  ## Examples

      iex> get_tier!(123)
      %Tier{}

      iex> get_tier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tier!(id), do: Repo.get!(Tier, id)

  @doc """
  Creates a tier.

  ## Examples

      iex> create_tier(%{field: value})
      {:ok, %Tier{}}

      iex> create_tier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tier(attrs \\ %{}) do
    %Tier{}
    |> Tier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tier.

  ## Examples

      iex> update_tier(tier, %{field: new_value})
      {:ok, %Tier{}}

      iex> update_tier(tier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tier(%Tier{} = tier, attrs) do
    tier
    |> Tier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tier.

  ## Examples

      iex> delete_tier(tier)
      {:ok, %Tier{}}

      iex> delete_tier(tier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tier(%Tier{} = tier) do
    Repo.delete(tier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tier changes.

  ## Examples

      iex> change_tier(tier)
      %Ecto.Changeset{data: %Tier{}}

  """
  def change_tier(%Tier{} = tier, attrs \\ %{}) do
    Tier.changeset(tier, attrs)
  end

  @doc """
  Returns the next priority a tier should have.

  ## Examples

      iex> get_next_tier_priority()
      5
  """
  def get_next_tier_priority do
    (Repo.aggregate(from(t in Tier), :max, :priority) || -1) + 1
  end

  @doc """
  Updates the spotlight configuration for a given tier.

  ## Examples

      iex> update_tier_spotlight_configuration(tier, 1.5, 10)
      {:ok, %Tier{}}
  """
  def update_tier_spotlight_configuration(%Tier{} = tier, spotlight_multiplier, max_spotlights) do
    tier
    |> Tier.changeset_multiplier(%{
      spotlight_multiplier: spotlight_multiplier,
      max_spotlights: max_spotlights
    })
    |> Repo.update()
  end

  @doc """
  Changes the multiplier for a given tier.

  ## Examples

      iex> change_tier_multiplier(tier, %{multiplier: 1.5})
      %Ecto.Changeset{data: %Tier{}, changes: %{multiplier: 1.5}}
  """
  def change_tier_multiplier(%Tier{} = tier, attrs \\ %{}) do
    Tier.changeset_multiplier(tier, attrs)
  end

  @doc """
  Retrieves the count of spotlights for a given company.

  ## Examples

      iex> get_company_spotlights_count(123)
      5
  """
  def get_company_spotlights_count(company_id) do
    Spotlight
    |> where([s], s.company_id == ^company_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Determines if a company can create a new spotlight based on its current tier and the number of existing spotlights.

  ## Examples

      iex> can_create_spotlight?(123)
      true

      iex> can_create_spotlight?(456)
      false
  """
  def can_create_spotlight?(company_id) do
    company = get_company!(company_id)
    tier = Repo.preload(company, :tier).tier

    current_spotlights_count = get_company_spotlights_count(company_id)

    current_spotlights_count < tier.max_spotlights
  end

  @doc """
  Returns the list of tiers with companies.
  """
  def list_tiers_with_companies do
    Tier
    |> order_by(:priority)
    |> preload(:companies)
    |> Repo.all()
  end

  @doc """
  Gets the URL's for the CV's the company has access to
  """
  def get_cvs(company) when not is_nil(company.badge_id) do
    if company.tier.full_cv_access do
      Accounts.list_users_with_cv()
      |> Enum.map(fn user ->
        {user.handle, Uploaders.CV.url({user.cv, user}, :original, signed: true)}
      end)
    else
      Contest.list_users_with_badge_and_cv(company.badge_id)
      |> Enum.map(fn user ->
        {user.handle, Uploaders.CV.url({user.cv, user}, :original, signed: true)}
      end)
    end
  end
end
