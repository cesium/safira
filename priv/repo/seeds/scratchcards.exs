defmodule Safira.Repo.Seeds.ScratchCards do
  alias Safira.Minigames

  def run do
    case Minigames.list_scratch_card_symbols() do
      [] ->
        seed_scratch_card_symbols()
        seed_scratch_card_drops()

      _ ->
        Mix.shell().error("Scratchcard seeds already exist, aborting seeding scratchcards.")
    end
  end

  defp seed_scratch_card_symbols do
    # Use the same reel images as slots
    files = [
      "reel1.svg", "reel2.svg", "reel3.svg", "reel4.svg", "reel5.svg",
      "reel6.svg", "reel7.svg", "reel8.svg", "reel9.svg", "reel10.svg", "reel11.svg"
    ]

    # Map symbols to readable names
    symbol_names = %{
      "reel1.svg" => "S",
      "reel2.svg" => "Void",
      "reel3.svg" => "CeSIUM",
      "reel4.svg" => "trophy",
      "reel5.svg" => "Void",
      "reel6.svg" => "pointer",
      "reel7.svg" => "bug",
      "reel8.svg" => "disc",
      "reel9.svg" => "UM",
      "reel10.svg" => "E",
      "reel11.svg" => "I"
    }

    for file <- files do
      plug_upload = %Plug.Upload{
        filename: file,
        path: Path.expand("priv/fake/images/#{file}", File.cwd!())
      }

      attrs = %{
        name: Map.get(symbol_names, file, file),
        image: plug_upload
      }

      case Minigames.create_scratch_card_symbol(attrs) do
        {:ok, symbol} ->
          # Immediately update the image using the dedicated update function
          case Minigames.update_scratch_card_symbol_image(symbol, %{image: plug_upload}) do
            {:ok, _updated_symbol} ->
              :ok
            {:error, changeset} ->
              Mix.shell().error("Failed to update scratch card symbol image for #{file}: #{inspect(changeset.errors)}")
          end

        {:error, changeset} ->
          Mix.shell().error("Failed to create scratch card symbol #{file}: #{inspect(changeset.errors)}")
      end
    end
  end

  defp seed_scratch_card_drops do
    symbols = Minigames.list_scratch_card_symbols()

    drops = [
      %{probability: 0.30, max_per_attendee: 10, tokens: 10},
      %{probability: 0.15, max_per_attendee: 5, tokens: 25},
      %{probability: 0.10, max_per_attendee: 3, tokens: 50},

      %{probability: 0.12, max_per_attendee: 5, entries: 1},
      %{probability: 0.06, max_per_attendee: 3, entries: 2},

      %{probability: 0.05, max_per_attendee: 2, tokens: 100},
      %{probability: 0.02, max_per_attendee: 1, tokens: 250},

      %{probability: 0.04, max_per_attendee: 2, tokens: 50, entries: 1},

      %{probability: 0.01, max_per_attendee: 1, tokens: 500},
      %{probability: 0.005, max_per_attendee: 1, tokens: 1000},
    ]

    symbols
    |> Enum.shuffle()
    |> Enum.zip(drops)
    |> Enum.each(fn {symbol, attrs} ->
      drop_attrs = Map.put(attrs, :scratch_card_symbol_id, symbol.id)

      case Minigames.create_scratch_card_drop(drop_attrs) do
        {:ok, _drop} ->
          :ok

        {:error, changeset} ->
          Mix.shell().error("Failed to seed scratch card drop: #{inspect(changeset.errors)}")
      end
    end)
  end
end

Safira.Repo.Seeds.ScratchCards.run()
