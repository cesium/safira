defmodule Safira.Repo.Seeds.Event do
  alias Safira.Event

  @faqs File.read!("priv/fake/faqs.txt") |> String.split("\n") |> Enum.map(&String.split(&1, ";"))

  def run do
    case Event.list_faqs() do
      [] ->
        seed_faqs()

      _ ->
        Mix.shell().error("Found FAQs, aborting seeding FAQs.")
    end
  end

  defp seed_faqs() do
    @faqs
    |> Enum.each(fn faq ->
      %{
        question: Enum.at(faq, 0),
        answer: Enum.at(faq, 1)
      }
      |> Event.create_faq() end)
  end
end

Safira.Repo.Seeds.Event.run()
