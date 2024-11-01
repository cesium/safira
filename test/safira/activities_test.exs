defmodule Safira.ActivitiesTest do
  use Safira.DataCase

  alias Safira.Activities

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
      assert Activities.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
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
      assert activity == Activities.get_activity!(activity.id)
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
end
