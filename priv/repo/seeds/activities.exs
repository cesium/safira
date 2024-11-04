defmodule Safira.Repo.Seeds.Activities do
  alias Safira.Repo

  alias Safira.Activities
  alias Safira.Activities.{Activity, ActivityCategory, Speaker}

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
    categories = (Activities.list_activity_categories() |> Enum.map(&(&1.id))) ++ [nil]
    speakers = Activities.list_speakers() |> Enum.map(&(&1.id))

    for day <- 0..3 do
      for i <- 0..5 do
        time_start = ~T[09:00:00] |> Time.add(i * 2, :hour)
        time_end = time_start |> Time.add(1, :hour)

        activity = %{
          title: Faker.Company.bs() |> String.capitalize(),
          location: "CP#{:rand.uniform(4)} - #{Enum.random(["A", "B"])}#{:rand.uniform(2)}",
          date: next_first_tuesday_of_february() |> Date.shift(day: day),
          time_start: time_start,
          time_end: time_end,
          description: Faker.Lorem.paragraph(3),
          category_id: Enum.random(categories),
        }

        changeset = Activities.change_activity(%Activity{}, activity)

        case Repo.insert(changeset) do
          {:ok, activity} ->
            speaker_ids = Enum.take_random(speakers, :rand.uniform(3))
            Activities.upsert_activity_speakers(Map.put(activity, :speakers, []), speaker_ids)
          {:error, changeset} ->
            Mix.shell().error("Failed to insert activity: #{activity.title}")
            Mix.shell().error(Kernel.inspect(changeset.errors))
        end
      end
    end
  end

  def next_first_tuesday_of_february do
    today = Date.utc_today()
    {year, _, _} = Date.to_erl(today)

    # Determine if we need to check this year or next year
    target_year =
      if today > Date.from_iso8601!("#{year}-02-01") do
        year + 1
      else
        year
      end

    # Find the first day of February for the target year
    february_first = Date.from_iso8601!("#{target_year}-02-01")

    # Calculate how many days to add to reach the first Tuesday
    days_to_add = rem(9 - Date.day_of_week(february_first), 7)

    # Add the days to February 1st to get the first Tuesday
    Date.add(february_first, days_to_add)
  end
end

Safira.Repo.Seeds.Activities.run()
