defmodule Safira.InteractionTest do
  use Safira.DataCase

  alias Safira.Interaction

  describe "spotlights" do
    alias Safira.Interaction.Spotlight

    @valid_attrs %{active: true}
    @update_attrs %{active: false}
    @invalid_attrs %{active: nil}

    def spotlight_fixture(attrs \\ %{}) do
      {:ok, spotlight} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Interaction.create_spotlight()

      spotlight
    end

    test "paginate_spotlights/1 returns paginated list of spotlights" do
      for _ <- 1..20 do
        spotlight_fixture()
      end

      {:ok, %{spotlights: spotlights} = page} = Interaction.paginate_spotlights(%{})

      assert length(spotlights) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_spotlights/0 returns all spotlights" do
      spotlight = spotlight_fixture()
      assert Interaction.list_spotlights() == [spotlight]
    end

    test "get_spotlight!/1 returns the spotlight with given id" do
      spotlight = spotlight_fixture()
      assert Interaction.get_spotlight!(spotlight.id) == spotlight
    end

    test "create_spotlight/1 with valid data creates a spotlight" do
      assert {:ok, %Spotlight{} = spotlight} = Interaction.create_spotlight(@valid_attrs)
      assert spotlight.active == true
    end

    test "create_spotlight/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Interaction.create_spotlight(@invalid_attrs)
    end

    test "update_spotlight/2 with valid data updates the spotlight" do
      spotlight = spotlight_fixture()
      assert {:ok, spotlight} = Interaction.update_spotlight(spotlight, @update_attrs)
      assert %Spotlight{} = spotlight
      assert spotlight.active == false
    end

    test "update_spotlight/2 with invalid data returns error changeset" do
      spotlight = spotlight_fixture()
      assert {:error, %Ecto.Changeset{}} = Interaction.update_spotlight(spotlight, @invalid_attrs)
      assert spotlight == Interaction.get_spotlight!(spotlight.id)
    end

    test "delete_spotlight/1 deletes the spotlight" do
      spotlight = spotlight_fixture()
      assert {:ok, %Spotlight{}} = Interaction.delete_spotlight(spotlight)
      assert_raise Ecto.NoResultsError, fn -> Interaction.get_spotlight!(spotlight.id) end
    end

    test "change_spotlight/1 returns a spotlight changeset" do
      spotlight = spotlight_fixture()
      assert %Ecto.Changeset{} = Interaction.change_spotlight(spotlight)
    end
  end
end
