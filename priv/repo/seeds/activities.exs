defmodule Safira.Repo.Seeds.Activities do
  alias Safira.Repo

  alias Safira.Activities
  alias Safira.Activities.{ActivityCategory, Speaker}

  def run do
    case Activities.list_activity_categories() do
      [] ->
        seed_categories()
      _  ->
        Mix.shell().error("Found categories, aborting seeding categories.")
    end

    case Activities.list_speakers() do
      [] ->
        seed_speakers()
      _  ->
        Mix.shell().error("Found speakers, aborting seeding speakers.")
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

  def seed_speakers do
    for i <- 1..30 do
      first_name = Faker.Person.first_name()
      last_name = Faker.Person.last_name()
      handle = "#{first_name}#{last_name}" |> String.downcase()

      speaker = %{
        name: "#{first_name} #{last_name}",
        title: Faker.Person.title(),
        company: Faker.Company.name(),
        biography: Faker.Lorem.paragraph(3),
        highlighted: i > 24,
        socials: %{
          x: handle |> String.slice(0..14),
          linkedin: handle,
          github: handle,
          website: Faker.Internet.url()
        }
      }

      changeset = Speaker.changeset(%Speaker{}, speaker)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert speaker: #{speaker.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_activities do
    # TODO: Add activity seeds
  end
end

Safira.Repo.Seeds.Activities.run()
