defmodule Safira.Interactions do
  @moduledoc """
  The Interactions context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo

alias Safira.Interactions.Bonus

@doc """
Returns the list of bonuses.

## Examples

    iex> list_bonuses()
    [%Bonus{}, ...]

"""
def list_bonuses do
  Repo.all(Bonus)
end

@doc """
Gets a single bonus.

Raises `Ecto.NoResultsError` if the Bonus does not exist.

## Examples

    iex> get_bonus!(123)
    %Bonus{}

    iex> get_bonus!(456)
    ** (Ecto.NoResultsError)

"""
def get_bonus!(id), do: Repo.get!(Bonus, id)

@doc """
Creates a bonus.

## Examples

    iex> create_bonus(%{field: value})
    {:ok, %Bonus{}}

    iex> create_bonus(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

"""
def create_bonus(attrs \\ %{}) do
  %Bonus{}
  |> Bonus.changeset(attrs)
  |> Repo.insert()
end

@doc """
Updates a bonus.

## Examples

    iex> update_bonus(bonus, %{field: new_value})
    {:ok, %Bonus{}}

    iex> update_bonus(bonus, %{field: bad_value})
    {:error, %Ecto.Changeset{}}

"""
def update_bonus(%Bonus{} = bonus, attrs) do
  bonus
  |> Bonus.changeset(attrs)
  |> Repo.update()
end

@doc """
Deletes a Bonus.

## Examples

    iex> delete_bonus(bonus)
    {:ok, %Bonus{}}

    iex> delete_bonus(bonus)
    {:error, %Ecto.Changeset{}}

"""
def delete_bonus(%Bonus{} = bonus) do
  Repo.delete(bonus)
end

@doc """
Returns an `%Ecto.Changeset{}` for tracking bonus changes.

## Examples

    iex> change_bonus(bonus)
    %Ecto.Changeset{source: %Bonus{}}

"""
def change_bonus(%Bonus{} = bonus) do
  Bonus.changeset(bonus, %{})
end
end
