defmodule Safira.ContestFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Contest` context.
  """

  alias Safira.AccountsFixtures
  alias Safira.Contest

  @doc """
  Generate a badge.
  """
  def badge_fixture(attrs \\ %{}) do
    {:ok, badge} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        tokens: 42,
        entries: 2,
        category_id: badge_category_fixture().id,
        begin: ~U[2021-01-01 00:00:00Z],
        end: ~U[2021-01-01 00:00:00Z]
      })
      |> Safira.Contest.create_badge()

    badge
  end

  @doc """
  Generate a badge_redeem.
  """
  def badge_redeem_fixture(attrs \\ %{}) do
    {:ok, badge_redeem} =
      attrs
      |> Enum.into(%{
        badge_id: badge_fixture().id,
        attendee_id: AccountsFixtures.attendee_fixture().id
      })
      |> Safira.Contest.create_badge_redeem()

    badge_redeem
  end

  @doc """
  Generate a badge_category
  """
  def badge_category_fixture(attrs \\ %{}) do
    {:ok, badge_category} =
      attrs
      |> Enum.into(%{
        name: "some name",
        color: "red",
        hidden: false
      })
      |> Safira.Contest.create_badge_category()

    badge_category
  end

  @doc """
  Generate a badge_trigger.
  """
  def badge_trigger_fixture(attrs \\ %{}) do
    {:ok, badge_trigger} =
      attrs
      |> Enum.into(%{
        badge_id: badge_fixture().id,
        event: Contest.BadgeTrigger.events() |> Enum.random()
      })
      |> Safira.Contest.create_badge_trigger()

    badge_trigger
  end
end
