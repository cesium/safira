defmodule Safira.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Safira.Activities` context.
  """

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        date: ~D[2024-10-27],
        description: "some description",
        has_enrolments: true,
        location: "some location",
        time_end: ~T[14:00:00],
        time_start: ~T[14:00:00],
        title: "some title"
      })
      |> Safira.Activities.create_activity()

    activity
  end

  @doc """
  Generate a activity_category.
  """
  def activity_category_fixture(attrs \\ %{}) do
    {:ok, activity_category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Safira.Activities.create_activity_category()

    activity_category
  end

  @doc """
  Generate a speaker.
  """
  def speaker_fixture(attrs \\ %{}) do
    {:ok, speaker} =
      attrs
      |> Enum.into(%{
        biography: "some biography",
        company: "some company",
        highlighted: true,
        name: "some name",
        title: "some title"
      })
      |> Safira.Activities.create_speaker()

    speaker
  end
end
