defmodule Safira.Admin.Accounts do
  @moduledoc """
  The Admin.Accounts context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo
  alias Safira.Admin.Accounts.AdminUser
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Safira.Accounts.Attendee

  @pagination [page_size: 15]
  @pagination_distance 5

  def list_admin_users do
    Repo.all(AdminUser)
  end

  @doc """
  Paginate the list of attendees using filtrex
  filters.

  ## Examples

      iex> list_attendees(%{})
      %{attendees: [%Attendee{}], ...}
  """
  @spec paginate_attendees(map) :: {:ok, map} | {:error, any}
  def paginate_attendees(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:attendees), params["attendee"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_attendees(filter, params) do
      {:ok,
       %{
         attendees: page.entries,
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

  defp do_paginate_attendees(filter, params) do
    Attendee
    |> Filtrex.query(filter)
    |> where([a], not(is_nil(a.user_id)))
    |> preload(:user)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of attendees.

  ## Examples

      iex> list_attendees()
      [%Attendee{}, ...]

  """
  def list_attendees do
    Repo.all(Attendee)
  end

  @doc """
  Gets a single attendee.

  Raises `Ecto.NoResultsError` if the Attendee does not exist.

  ## Examples

      iex> get_attendee!(123)
      %Attendee{}

      iex> get_attendee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendee!(id), do: Repo.get!(Attendee, id)

  @doc """
  Creates a attendee.

  ## Examples

      iex> create_attendee(%{field: value})
      {:ok, %Attendee{}}

      iex> create_attendee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendee(attrs \\ %{}) do
    %Attendee{}
    |> Attendee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attendee.

  ## Examples

      iex> update_attendee(attendee, %{field: new_value})
      {:ok, %Attendee{}}

      iex> update_attendee(attendee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendee(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Attendee.

  ## Examples

      iex> delete_attendee(attendee)
      {:ok, %Attendee{}}

      iex> delete_attendee(attendee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendee(%Attendee{} = attendee) do
    Repo.delete(attendee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendee changes.

  ## Examples

      iex> change_attendee(attendee)
      %Ecto.Changeset{source: %Attendee{}}

  """
  def change_attendee(%Attendee{} = attendee) do
    Attendee.changeset(attendee, %{})
  end

  defp filter_config(:attendees) do
    defconfig do
    end
  end
end
