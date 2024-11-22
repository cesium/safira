defmodule Safira.SpotlightsTest do
  use Safira.DataCase

  alias Safira.Spotlights

  describe "spotlights" do
    alias Safira.Spotlights.Spotlight

    import Safira.SpotlightsFixtures

    @invalid_attrs %{end: nil}

    test "list_spotlights/0 returns all spotlights" do
      spotlight = spotlight_fixture()
      assert Spotlights.list_spotlights() == [spotlight]
    end

    test "get_spotlight!/1 returns the spotlight with given id" do
      spotlight = spotlight_fixture()
      assert Spotlights.get_spotlight!(spotlight.id) == spotlight
    end

    test "create_spotlight/1 with valid data creates a spotlight" do
      valid_attrs = %{end: ~U[2024-11-20 22:32:00Z]}

      assert {:ok, %Spotlight{} = spotlight} = Spotlights.create_spotlight(valid_attrs)
      assert spotlight.end == ~U[2024-11-20 22:32:00Z]
    end

    test "create_spotlight/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spotlights.create_spotlight(@invalid_attrs)
    end

    test "update_spotlight/2 with valid data updates the spotlight" do
      spotlight = spotlight_fixture()
      update_attrs = %{end: ~U[2024-11-21 22:32:00Z]}

      assert {:ok, %Spotlight{} = spotlight} = Spotlights.update_spotlight(spotlight, update_attrs)
      assert spotlight.end == ~U[2024-11-21 22:32:00Z]
    end

    test "update_spotlight/2 with invalid data returns error changeset" do
      spotlight = spotlight_fixture()
      assert {:error, %Ecto.Changeset{}} = Spotlights.update_spotlight(spotlight, @invalid_attrs)
      assert spotlight == Spotlights.get_spotlight!(spotlight.id)
    end

    test "delete_spotlight/1 deletes the spotlight" do
      spotlight = spotlight_fixture()
      assert {:ok, %Spotlight{}} = Spotlights.delete_spotlight(spotlight)
      assert_raise Ecto.NoResultsError, fn -> Spotlights.get_spotlight!(spotlight.id) end
    end

    test "change_spotlight/1 returns a spotlight changeset" do
      spotlight = spotlight_fixture()
      assert %Ecto.Changeset{} = Spotlights.change_spotlight(spotlight)
    end
  end
end
