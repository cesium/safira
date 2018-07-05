defmodule Safira.Contest do

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Contest.Badge

  def list_badges do
    Repo.all(Badge)
  end

  def get_badge!(id), do: Repo.get!(Badge, id)

  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end

  alias Safira.Contest.Referral

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
  def get_referral!(id), do: Repo.get!(Referral, id)

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
end
