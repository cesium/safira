defmodule Safira.Challenges do
  @moduledoc """
  The Challenges context
  """

  use Safira.Context

  alias Safira.Challenges.{Challenge, ChallengePrize}

  @doc """
  Returns the list of challenges.

  ## Examples

      iex> list_challenges()
      [%Challenge{}, ...]

  """
  def list_challenges do
    Challenge
    |> order_by([c], asc: c.display_priority)
    |> Repo.all()
    |> Repo.preload(prizes: [:prize])
  end

  def list_challenges(opts) when is_list(opts) do
    Challenge
    |> order_by([c], asc: c.display_priority)
    |> apply_filters(opts)
    |> Repo.all()
    |> Repo.preload(prizes: [:prize])
  end

  def list_challenges(params) do
    Challenge
    |> order_by([c], asc: c.display_priority)
    |> Flop.validate_and_run(params, for: Challenge, preload: [prizes: [:prize]])
  end

  def list_challenges(%{} = params, opts) when is_list(opts) do
    Challenge
    |> order_by([c], asc: c.display_priority)
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Challenge, preload: [prizes: [:prize]])
  end

  @doc """
  Gets a single challenge.

  Raises `Ecto.NoResultsError` if the Challenge does not exist.

  ## Examples

      iex> get_challenge!(123)
      %Challenge{}

      iex> get_challenge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_challenge!(id), do: Repo.get!(Challenge, id) |> Repo.preload(prizes: [:prize])

  @doc """
  Creates a challenge.

  ## Examples

      iex> create_challenge(%{field: value})
      {:ok, %Challenge{}}

      iex> create_challenge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_challenge(attrs \\ %{}) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a challenge.

  ## Examples

      iex> update_challenge(challenge, %{field: new_value})
      {:ok, %Challenge{}}

      iex> update_challenge(challenge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_challenge(%Challenge{} = challenge, attrs) do
    challenge
    |> Challenge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a challenge.

  ## Examples

      iex> delete_challenge(challenge)
      {:ok, %Challenge{}}

      iex> delete_challenge(challenge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_challenge(%Challenge{} = challenge) do
    Repo.delete(challenge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking challenge changes.

  ## Examples

      iex> change_challenge(challenge)
      %Ecto.Changeset{data: %Challenge{}}

  """
  def change_challenge(%Challenge{} = challenge, attrs \\ %{}) do
    Challenge.changeset(challenge, attrs)
  end

  @doc """
  Returns the list of challenges_prizes.

  ## Examples

      iex> list_challenges_prizes()
      [%ChallengePrize{}, ...]

  """
  def list_challenges_prizes do
    Repo.all(ChallengePrize)
  end

  @doc """
  Gets a single challenge_prize.

  Raises `Ecto.NoResultsError` if the ChallengePrize does not exist.

  ## Examples

      iex> get_challenge_prize!(123)
      %ChallengePrize{}

      iex> get_challenge_prize!(456)
      ** (Ecto.NoResultsError)

  """
  def get_challenge_prize!(id), do: Repo.get!(ChallengePrize, id)

  @doc """
  Creates a challenge_prize.

  ## Examples

      iex> create_challenge_prize(%{field: value})
      {:ok, %ChallengePrize{}}

      iex> create_challenge_prize(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_challenge_prize(attrs \\ %{}) do
    %ChallengePrize{}
    |> ChallengePrize.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a challenge_prize.

  ## Examples

      iex> update_challenge_prize(challenge, %{field: new_value})
      {:ok, %ChallengePrize{}}

      iex> update_challenge(challenge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_challenge_prize(%ChallengePrize{} = challenge_prize, attrs) do
    challenge_prize
    |> ChallengePrize.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a challenge_prize.

  ## Examples

      iex> delete_challenge_prize(challenge)
      {:ok, %Challenge{}}

      iex> delete_challenge_prize(challenge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_challenge_prize(%ChallengePrize{} = challenge_prize) do
    Repo.delete(challenge_prize)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking challenge_prize changes.

  ## Examples

      iex> change_challenge(challenge_prize)
      %Ecto.Changeset{data: %ChallengePrize{}}

  """
  def change_challenge_prize(%ChallengePrize{} = challenge_prize, attrs \\ %{}) do
    ChallengePrize.changeset(challenge_prize, attrs)
  end
end
