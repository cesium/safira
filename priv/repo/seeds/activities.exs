defmodule Safira.Repo.Seeds.Activities do
  alias Safira.Repo

  alias Safira.Activities
  alias Safira.Activities.{Activity, ActivityCategory, Speaker}
  alias Safira.Event

  def run do
    seed_event_schedule_config()

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

  def seed_event_schedule_config do
    event_start_date = next_first_tuesday_of_february()
    Event.change_event_start_date(event_start_date)
    Event.change_event_end_date(Date.add(event_start_date, 3))
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
        name: "Gameshow"
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
    category_list = Activities.list_activity_categories()
    speakers = Activities.list_speakers() |> Enum.map(&(&1.id))

    categories = %{
      none: %{id: nil},
      talk: Enum.find(category_list, fn category -> category.name == "Talk" end),
      pitch: Enum.find(category_list, fn category -> category.name == "Pitch" end),
      gameshow: Enum.find(category_list, fn category -> category.name == "Gameshow" end),
      workshop: Enum.find(category_list, fn category -> category.name == "Workshop" end),
      break: Enum.find(category_list, fn category -> category.name == "Break" end)
    }

    seed_first_day_activities(categories, speakers)
    seed_last_days_activities(categories, speakers)
  end

  defp seed_first_day_activities(categories, speakers) do
    for activity <- first_day_seed_data() do
      type = activity.type
      changeset = Activities.change_activity(%Activity{},
        activity
        |> Map.put(:date, next_first_tuesday_of_february())
        |> Map.put(:category_id, Map.get(categories, type).id)
        |> Map.put(:title, Map.get(activity, :title) || Faker.Company.bs() |> String.capitalize())
        |> Map.put(:location, Map.get(activity, :location) || "CP2 - B1"))

      insert_activity(changeset, type, speakers)
    end
  end

  defp seed_last_days_activities(categories, speakers) do
    for i <- 1..3 do
      for activity <- last_days_seed_data() do
        type = activity.type
        changeset = Activities.change_activity(%Activity{},
          activity
          |> Map.put(:date, Date.shift(next_first_tuesday_of_february(), day: i))
          |> Map.put(:category_id, Map.get(categories, type).id)
          |> Map.put(:title, Map.get(activity, :title) || Faker.Company.bs() |> String.capitalize())
          |> Map.put(:location, Map.get(activity, :location) || "CP2 - B1"))

        insert_activity(changeset, type, speakers)
      end
    end
  end

  defp insert_activity(changeset, type, speakers) do
    case Repo.insert(changeset) do
      {:ok, activity} ->
        speaker_ids = Enum.take_random(speakers, :rand.uniform(3))
        if type in [:talk, :pitch, :workshop] do
          Activities.upsert_activity_speakers(Map.put(activity, :speakers, []), speaker_ids)
        end
      {:error, changeset} ->
        Mix.shell().error("Failed to insert activity: #{changeset.title}")
        Mix.shell().error(Kernel.inspect(changeset.errors))
    end
  end

  defp next_first_tuesday_of_february do
    today = Date.utc_today()
    {year, _, _} = Date.to_erl(today)

    # Determine if we need to check this year or next year
    target_year =
      if Date.compare(today, Date.from_iso8601!("#{year}-02-01")) == :gt do
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

  defp first_day_seed_data do
    [
      %{
        title: "Opening Ceremony",
        time_start: ~T[10:00:00],
        time_end: ~T[11:00:00],
        location: "CP2 - B1",
        type: :none
      },
      %{
        title: "Prizes and Contests",
        time_start: ~T[11:00:00],
        time_end: ~T[11:30:00],
        location: "CP2 - B1",
        type: :none
      },
      %{
        title: "Coffee Break",
        time_start: ~T[11:30:00],
        time_end: ~T[12:00:00],
        type: :break,
      },
      %{
        time_start: ~T[12:00:00],
        time_end: ~T[13:00:00],
        type: :talk,
      },
      %{
        title: "Lunch Break",
        time_start: ~T[13:00:00],
        time_end: ~T[14:00:00],
        type: :break,
      },
      %{
        time_start: ~T[14:00:00],
        time_end: ~T[15:00:00],
        type: :talk
      },
      %{
        time_start: ~T[15:00:00],
        time_end: ~T[16:00:00],
        type: :talk
      },
      %{
        title: "Coffee Break",
        time_start: ~T[16:00:00],
        time_end: ~T[16:30:00],
        type: :break,
      },
      %{
        time_start: ~T[16:30:00],
        time_end: ~T[16:45:00],
        type: :pitch,
      },
      %{
        time_start: ~T[16:45:00],
        time_end: ~T[17:00:00],
        type: :pitch,
      },
      %{
        time_start: ~T[17:00:00],
        time_end: ~T[18:00:00],
        type: :gameshow
      }
    ]
  end

  defp last_days_seed_data do
    [
      %{
        time_start: ~T[09:00:00],
        time_end: ~T[11:00:00],
        location: "CP2 - 0.14",
        type: :workshop
      },
      %{
        time_start: ~T[09:00:00],
        time_end: ~T[11:00:00],
        location: "CP2 - 0.15",
        type: :workshop
      },
      %{
        time_start: ~T[09:00:00],
        time_end: ~T[11:00:00],
        location: "CP2 - 0.17",
        type: :workshop
      },
      %{
        title: "Coffee Break",
        time_start: ~T[11:00:00],
        time_end: ~T[11:30:00],
        type: :break,
      },
      %{
        time_start: ~T[11:30:00],
        time_end: ~T[12:30:00],
        location: "CP2 - B1",
        type: :talk
      },
      %{
        title: "Lunch Break",
        time_start: ~T[12:30:00],
        time_end: ~T[14:00:00],
        type: :break,
      },
      %{
        time_start: ~T[14:00:00],
        time_end: ~T[15:00:00],
        type: :talk
      },
      %{
        time_start: ~T[15:00:00],
        time_end: ~T[16:00:00],
        type: :talk
      },
      %{
        title: "Coffee Break",
        time_start: ~T[16:00:00],
        time_end: ~T[16:30:00],
        type: :break,
      },
      %{
        time_start: ~T[16:30:00],
        time_end: ~T[16:45:00],
        type: :pitch
      },
      %{
        time_start: ~T[16:45:00],
        time_end: ~T[17:00:00],
        type: :pitch
      },
      %{
        time_start: ~T[17:00:00],
        time_end: ~T[18:00:00],
        type: :talk
      }
    ]
  end
end

Safira.Repo.Seeds.Activities.run()
