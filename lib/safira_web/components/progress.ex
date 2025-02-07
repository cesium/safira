defmodule SafiraWeb.Components.Progress do
  @moduledoc """
  Progress bar component.
  """
  use SafiraWeb, :component

  attr :progress, :integer, required: true

  def progress(assigns) do
    ~H"""
    <div class="relative w-full h-2 bg-lightShade dark:bg-darkShade rounded-full">
      <div
        class="absolute top-0 left-0 h-full rounded-full bg-accent transition-all"
        style={"width: #{@progress}%"}
      >
      </div>
    </div>
    """
  end
end
