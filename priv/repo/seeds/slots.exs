defmodule Safira.Repo.Seeds.Slots do
  alias Safira.Minigames

  def run do
    case Minigames.list_slots_paytables() do
      [] ->
        seed_slots_paytables()
        seed_slots_paylines()
        seed_slots_reel_icons()

      _ ->
        Mix.shell().info("Slots seeds already exist, aborting seeding slots.")
    end
  end

  defp seed_slots_paytables do
    paytables = [
      %{multiplier: 1, probability: 0.3},
      %{multiplier: 2, probability: 0.08},
      %{multiplier: 3, probability: 0.04},
      %{multiplier: 5, probability: 0.025},
      %{multiplier: 10, probability: 0.00499},
      %{multiplier: 100, probability: 0.00001}
    ]

    for attrs <- paytables do
      case Minigames.create_slots_paytable(attrs) do
        {:ok, _paytable} ->
          :ok

        {:error, changeset} ->
          Mix.shell().error("Failed to seed slots paytable: #{inspect(changeset.errors)}")
      end
    end
  end

  defp seed_slots_paylines do
    multiplier_paylines = %{
      100 => [[0, 0, 0]],
      10 => [[3, 3, 3]],
      5 => [
        [5, 5, 5],
        [5, 7, 7],
        [7, 5, 7],
        [7, 7, 5],
        [5, 5, 7],
        [5, 7, 5],
        [7, 5, 5],
        [7, 7, 7]
      ],
      3 => [
        [6, 0, 6],
        [6, 1, 6],
        [6, 2, 6],
        [6, 3, 6],
        [6, 4, 6],
        [6, 5, 6],
        [6, 6, 6],
        [6, 7, 6],
        [6, 8, 6]
      ],
      2 => [[2, 2, 2]],
      1 => [
        [1, 1, 1],
        [4, 1, 1],
        [1, 4, 1],
        [1, 1, 4],
        [4, 4, 1],
        [4, 1, 4],
        [1, 4, 4],
        [4, 4, 4]
      ]
    }

    paytables = Minigames.list_slots_paytables()

    for paytable <- paytables do
      paylines = Map.get(multiplier_paylines, paytable.multiplier, [])

      for [pos0, pos1, pos2] <- paylines do
        attrs = %{
          paytable_id: paytable.id,
          position_0: pos0,
          position_1: pos1,
          position_2: pos2
        }

        case Minigames.create_slots_payline(attrs) do
          {:ok, _payline} ->
            :ok

          {:error, changeset} ->
            Mix.shell().error("Failed to create slots payline: #{inspect(changeset.errors)}")
        end
      end
    end
  end

  defp seed_slots_reel_icons do
    files = [
      "reel1.svg", "reel2.svg", "reel3.svg", "reel4.svg", "reel5.svg",
      "reel6.svg", "reel7.svg", "reel8.svg", "reel9.svg", "reel10.svg", "reel11.svg"
    ]

    # Define ordering per reel
    reel0_order = ["reel1.svg", "reel2.svg", "reel3.svg", "reel4.svg", "reel5.svg", "reel6.svg", "reel7.svg", "reel8.svg", "reel9.svg"]
    reel1_order = ["reel10.svg", "reel2.svg", "reel3.svg", "reel4.svg", "reel5.svg", "reel6.svg", "reel7.svg", "reel8.svg", "reel9.svg"]
    reel2_order = ["reel11.svg", "reel2.svg", "reel3.svg", "reel4.svg", "reel5.svg", "reel6.svg", "reel7.svg", "reel8.svg", "reel9.svg"]

    for file <- files do
      plug_upload = %Plug.Upload{
        filename: file,
        path: Path.expand("priv/fake/images/#{file}", File.cwd!())
      }

      attrs = %{
        image: plug_upload,
        reel_0_index: index_in(file, reel0_order),
        reel_1_index: index_in(file, reel1_order),
        reel_2_index: index_in(file, reel2_order)
      }

      case Minigames.create_slots_reel_icon(attrs) do
        {:ok, icon} ->
          # Immediately update the image using the dedicated update function.
          case Minigames.update_slots_reel_icon_image(icon, %{image: plug_upload}) do
            {:ok, _updated_icon} ->
              Mix.shell().info("Created and updated reel icon #{file}")

            {:error, changeset} ->
              Mix.shell().error("Failed to update reel icon image for #{file}: #{inspect(changeset.errors)}")
          end

        {:error, changeset} ->
          Mix.shell().error("Failed to create reel icon #{file}: #{inspect(changeset.errors)}")
      end
    end
  end

  defp index_in(file, order) do
    case Enum.find_index(order, &(&1 == file)) do
      nil -> -1
      index -> index
    end
  end
end

Safira.Repo.Seeds.Slots.run()
