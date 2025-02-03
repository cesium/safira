defmodule Safira.Repo.Seeds.Badges do
  alias Safira.Contest
  alias Safira.Accounts.{Attendee, Staff}
  alias Safira.Contest.{Badge, BadgeCategory}
  alias Safira.Repo

  @badges File.read!("priv/fake/badges.txt") |> String.split("\n") |> Enum.map(&String.split(&1, ";"))

  def run do
    case Contest.list_badge_categories() do
      [] ->
        seed_categories()
      _  ->
        Mix.shell().error("Found categories, aborting seeding categories.")
    end

    case Contest.list_badges() do
      [] ->
        seed_badges()
      _  ->
        Mix.shell().error("Found badges, aborting seeding badges.")
    end
  end

  def seed_categories do
    categories = [
      %{
        name: "General",
        color: "red",
        hidden: false
      }
    ]

    for category <- categories do
      changeset = BadgeCategory.changeset(%BadgeCategory{}, category)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert category: #{category.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  def seed_badges do
    category = Repo.one(BadgeCategory, name: "General")
    {:ok, begin_time} = DateTime.from_unix(:erlang.system_time(:second))
    {:ok, end_time} = DateTime.from_unix(:erlang.system_time(:second) + 400_000)
    attendees = Repo.all(Attendee)
    staffs = Repo.all(Staff)

    for {badge, i} <- Enum.with_index(@badges) do
      {name, description} = {Enum.at(badge, 0), Enum.at(badge, 1)}

      badge_seed = %{
        name: name,
        description: description,
        tokens: :rand.uniform(999),
        begin: begin_time,
        end: end_time,
        category_id: category.id
      }

      changeset = Badge.changeset(%Badge{}, badge_seed)

      case Repo.insert(changeset) do
        {:ok, badge} ->
          for _ <- 1..10 do
            Contest.create_badge_redeem(%{
              badge_id: badge.id,
              attendee_id: Enum.random(attendees).id,
              redeemed_by_id: Enum.random(staffs).id
            })
          end

          :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert badge: #{name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end
end

Safira.Repo.Seeds.Badges.run()
