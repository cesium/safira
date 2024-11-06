defmodule SafiraWeb.Landing.Components.Speaker do
  @moduledoc """
  Speaker component.
  """
  use SafiraWeb, :component

  alias Safira.Activities.Speaker

  attr :speaker, Speaker, required: true

  def speaker(assigns) do
    ~H"""
    <div class="z-30 text-white grayscale filter transition-all hover:text-accent hover:filter-none">
      <img
        src={
          if @speaker.picture do
            Uploaders.Speaker.url({@speaker.picture, @speaker}, :original)
          else
            "https://github.com/identicons/#{@speaker.name |> String.slice(0..2)}.png"
          end
        }
        width="210"
        height="210"
        alt={@speaker.name}
        class="select-none"
      />
      <p class="text-md font-terminal uppercase"><%= @speaker.name %></p>
      <p class="text-md max-w-[210px] font-iregular"><%= @speaker.title %></p>
      <p class="text-md max-w-[210px] font-iregular"><%= @speaker.company %></p>
    </div>
    """
  end
end
