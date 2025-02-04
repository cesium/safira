defmodule Safira.ActivitiesTest do
  use Safira.DataCase

  alias Safira.Activities
  alias Safira.Event

  describe "activities" do
    alias Safira.Activities.Activity

    import Safira.ActivitiesFixtures

    @invalid_attrs %{
      date: nil,
      description: nil,
      title: nil,
      location: nil,
      time_start: nil,
      time_end: nil,
      has_enrolments: nil
    }

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Activities.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Activities.get_activity!(activity.id).id == activity.id
    end

    test "create_activity/1 with valid data creates a activity" do
      Event.change_event_start_date(~D[2024-10-27])
      Event.change_event_end_date(~D[2024-10-27])

      valid_attrs = %{
        date: ~D[2024-10-27],
        description: "some description",
        title: "some title",
        location: "some location",
        time_start: ~T[14:00:00],
        time_end: ~T[14:00:00],
        has_enrolments: true
      }

      assert {:ok, %Activity{} = activity} = Activities.create_activity(valid_attrs)
      assert activity.date == ~D[2024-10-27]
      assert activity.description == "some description"
      assert activity.title == "some title"
      assert activity.location == "some location"
      assert activity.time_start == ~T[14:00:00]
      assert activity.time_end == ~T[14:00:00]
      assert activity.has_enrolments == true
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()

      Event.change_event_start_date(~D[2024-10-28])
      Event.change_event_end_date(~D[2024-10-28])

      update_attrs = %{
        date: ~D[2024-10-28],
        description: "some updated description",
        title: "some updated title",
        location: "some updated location",
        time_start: ~T[15:01:01],
        time_end: ~T[15:01:01],
        has_enrolments: false
      }

      assert {:ok, %Activity{} = activity} = Activities.update_activity(activity, update_attrs)
      assert activity.date == ~D[2024-10-28]
      assert activity.description == "some updated description"
      assert activity.title == "some updated title"
      assert activity.location == "some updated location"
      assert activity.time_start == ~T[15:01:01]
      assert activity.time_end == ~T[15:01:01]
      assert activity.has_enrolments == false
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activity(activity, @invalid_attrs)
      assert activity.id == Activities.get_activity!(activity.id).id
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Activities.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity(activity)
    end
  end

  describe "activity_categories" do
    alias Safira.Activities.ActivityCategory

    import Safira.ActivitiesFixtures

    @invalid_attrs %{name: nil}

    test "list_activity_categories/0 returns all activity_categories" do
      activity_category = activity_category_fixture()
      assert Activities.list_activity_categories() == [activity_category]
    end

    test "get_activity_category!/1 returns the activity_category with given id" do
      activity_category = activity_category_fixture()
      assert Activities.get_activity_category!(activity_category.id) == activity_category
    end

    test "create_activity_category/1 with valid data creates a activity_category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ActivityCategory{} = activity_category} =
               Activities.create_activity_category(valid_attrs)

      assert activity_category.name == "some name"
    end

    test "create_activity_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity_category(@invalid_attrs)
    end

    test "update_activity_category/2 with valid data updates the activity_category" do
      activity_category = activity_category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ActivityCategory{} = activity_category} =
               Activities.update_activity_category(activity_category, update_attrs)

      assert activity_category.name == "some updated name"
    end

    test "update_activity_category/2 with invalid data returns error changeset" do
      activity_category = activity_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_activity_category(activity_category, @invalid_attrs)

      assert activity_category == Activities.get_activity_category!(activity_category.id)
    end

    test "delete_activity_category/1 deletes the activity_category" do
      activity_category = activity_category_fixture()
      assert {:ok, %ActivityCategory{}} = Activities.delete_activity_category(activity_category)

      assert_raise Ecto.NoResultsError, fn ->
        Activities.get_activity_category!(activity_category.id)
      end
    end

    test "change_activity_category/1 returns a activity_category changeset" do
      activity_category = activity_category_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity_category(activity_category)
    end
  end

  describe "speakers" do
    alias Safira.Activities.Speaker

    import Safira.ActivitiesFixtures

    @invalid_attrs %{name: nil, title: nil, company: nil, biography: nil, highlighted: nil}

    test "list_speakers/0 returns all speakers" do
      speaker = speaker_fixture()
      assert Activities.list_speakers() == [speaker]
    end

    test "get_speaker!/1 returns the speaker with given id" do
      speaker = speaker_fixture()
      assert Activities.get_speaker!(speaker.id) == speaker
    end

    test "create_speaker/1 with valid data creates a speaker" do
      valid_attrs = %{
        name: "some name",
        title: "some title",
        company: "some company",
        biography: "some biography",
        highlighted: true
      }

      assert {:ok, %Speaker{} = speaker} = Activities.create_speaker(valid_attrs)
      assert speaker.name == "some name"
      assert speaker.title == "some title"
      assert speaker.company == "some company"
      assert speaker.biography == "some biography"
      assert speaker.highlighted == true
    end

    test "create_speaker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_speaker(@invalid_attrs)
    end

    test "update_speaker/2 with valid data updates the speaker" do
      speaker = speaker_fixture()

      update_attrs = %{
        name: "some updated name",
        title: "some updated title",
        company: "some updated company",
        biography: "some updated biography",
        highlighted: false
      }

      assert {:ok, %Speaker{} = speaker} = Activities.update_speaker(speaker, update_attrs)
      assert speaker.name == "some updated name"
      assert speaker.title == "some updated title"
      assert speaker.company == "some updated company"
      assert speaker.biography == "some updated biography"
      assert speaker.highlighted == false
    end

    test "update_speaker/2 with invalid data returns error changeset" do
      speaker = speaker_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_speaker(speaker, @invalid_attrs)
      assert speaker == Activities.get_speaker!(speaker.id)
    end

    test "delete_speaker/1 deletes the speaker" do
      speaker = speaker_fixture()
      assert {:ok, %Speaker{}} = Activities.delete_speaker(speaker)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_speaker!(speaker.id) end
    end

    test "change_speaker/1 returns a speaker changeset" do
      speaker = speaker_fixture()
      assert %Ecto.Changeset{} = Activities.change_speaker(speaker)
    end
  end
end
