defmodule SafiraWeb.Landing.Components.Speaker do
  @moduledoc """
  Speaker component.
  """
  use SafiraWeb, :component

  alias Safira.Activities.Speaker

  attr :speaker, Speaker, required: true

  def speaker(assigns) do
    ~H"""
    <a
      href={speaker_link(@speaker)}
      class="text-white grayscale filter transition-all hover:text-accent hover:filter-none"
    >
      <img
        src={
          if @speaker.picture do
            Uploaders.Speaker.url({@speaker.picture, @speaker}, :original, signed: true)
          else
            "https://github.com/identicons/#{@speaker.name |> String.slice(0..2)}.png"
          end
        }
        width="210"
        height="210"
        alt={@speaker.name}
        class="select-none"
      />
      <p class="text-md font-terminal uppercase">{@speaker.name}</p>
      <p class="text-md max-w-[210px] font-iregular">{@speaker.title}</p>
      <p class="text-md max-w-[210px] font-iregular">{@speaker.company}</p>
    </a>
    """
  end

  defp speaker_link(speaker) do
    case Enum.at(speaker.activities, 0) do
      nil ->
        "/speakers"

      activity ->
        "/speakers?date=#{activity.date}&speaker_id=#{speaker.id}#sp-#{speaker.id}-#{activity.id}"
    end
  end
end
