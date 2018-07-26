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

  def list_referrals do
    Repo.all(Referral)
  end

  def get_referral!(id), do: Repo.get!(Referral, id)

  def create_referral(attrs \\ %{}) do
    %Referral{}
    |> Referral.changeset(attrs)
    |> Repo.insert()
  end

  def update_referral(%Referral{} = referral, attrs) do
    referral
    |> Referral.changeset(attrs)
    |> Repo.update()
  end

  def delete_referral(%Referral{} = referral) do
    Repo.delete(referral)
  end

  def change_referral(%Referral{} = referral) do
    Referral.changeset(referral, %{})
  end

  alias Safira.Contest.Redeem

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
  def get_redeem!(id), do: Repo.get!(Redeem, id)

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
end
