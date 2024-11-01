defmodule Safira.Repo.Seeds.Activities do
  alias Safira.Repo

  alias Safira.Activities
  alias Safira.Activities.ActivityCategory

  def run do
    case Activities.list_activity_categories() do
      [] ->
        seed_categories()
      _  ->
        Mix.shell().error("Found categories, aborting seeding categories.")
    end

    case Activities.list_activities() do
      [] ->
        seed_activities()
      _  ->
        Mix.shell().error("Found activities, aborting seeding activities.")
    end
  end

  def seed_categories do
    categories = [
      %{
        name: "Talk"
      },
      %{
        name: "Pitch"
      },
      %{
        name: "Workshop"
      },
      %{
        name: "Break"
      }
    ]

    for category <- categories do
      changeset = ActivityCategory.changeset(%ActivityCategory{}, category)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert category: #{category.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_activities do
    # TODO: Add activity seeds
  end
end

Safira.Repo.Seeds.Activities.run()
