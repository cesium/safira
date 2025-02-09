defmodule Safira.Repo.Seeds.Event do
  alias Safira.Event

  @faqs File.read!("priv/fake/faqs.txt") |> String.split("\n") |> Enum.map(&String.split(&1, ";"))

  def run do
    case Event.list_faqs() do
      [] ->
        seed_dates()
        seed_faqs()

      _ ->
        Mix.shell().error("Found FAQs, aborting seeding FAQs.")
    end
  end

  defp seed_dates do
    start_date = next_first_tuesday_of_february()
    end_date = Date.shift(start_date, day: 3)

    Event.change_event_start_date(start_date)
    Event.change_event_end_date(end_date)
  end

  defp seed_faqs do
    @faqs
    |> Enum.each(fn faq ->
      %{
        question: Enum.at(faq, 0),
        answer: Enum.at(faq, 1)
      }
      |> Event.create_faq() end)
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
end

Safira.Repo.Seeds.Event.run()
