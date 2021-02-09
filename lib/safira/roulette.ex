defmodule Safira.Roulette do
  @moduledoc """
  The Roulette context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

alias Safira.Roulette.Prize

@doc """
Returns the list of prizes.

## Examples

    iex> list_prizes()
    [%Prize{}, ...]

"""
def list_prizes do
  Repo.all(Prize)
end

@doc """
Gets a single prize.

Raises `Ecto.NoResultsError` if the Prize does not exist.

## Examples

    iex> get_prize!(123)
    %Prize{}

    iex> get_prize!(456)
    ** (Ecto.NoResultsError)

"""
def get_prize!(id), do: Repo.get!(Prize, id)

@doc """
Creates a prize.

## Examples

    iex> create_prize(%{field: value})
    {:ok, %Prize{}}

    iex> create_prize(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

"""
def create_prize(attrs \\ %{}) do
  %Prize{}
  |> Prize.changeset(attrs)
  |> Repo.insert()
end

@doc """
Updates a prize.

## Examples

    iex> update_prize(prize, %{field: new_value})
    {:ok, %Prize{}}

    iex> update_prize(prize, %{field: bad_value})
    {:error, %Ecto.Changeset{}}

"""
def update_prize(%Prize{} = prize, attrs) do
  prize
  |> Prize.changeset(attrs)
  |> Repo.update()
end

@doc """
Deletes a Prize.

## Examples

    iex> delete_prize(prize)
    {:ok, %Prize{}}

    iex> delete_prize(prize)
    {:error, %Ecto.Changeset{}}

"""
def delete_prize(%Prize{} = prize) do
  Repo.delete(prize)
end

@doc """
Returns an `%Ecto.Changeset{}` for tracking prize changes.

## Examples

    iex> change_prize(prize)
    %Ecto.Changeset{source: %Prize{}}

"""
def change_prize(%Prize{} = prize) do
  Prize.changeset(prize, %{})
end

end
