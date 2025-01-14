defmodule SafiraWeb.Landing.FAQLive.Components.Faq do
  @moduledoc false
  use SafiraWeb, :component

  attr :id, :string, required: true
  attr :question, :string, required: true
  attr :answer, :string, required: true

  def faq(assigns) do
    ~H"""
    <div id={@id} class="border-t-2 border-white py-4 text-white">
      <h2 class="font-terminal uppercase mb-4 select-none text-2xl md:text-4xl">
        <%= @question %>
      </h2>
      <div id={"faq-answer-#{@id}"} class="overflow-hidden pb-4" style="display: none;">
        <p><%= @answer %></p>
      </div>
      <div class="flex items-center justify-end">
        <button
          class="font-terminal uppercase w-16 select-none rounded-full bg-accent px-2 text-xl text-white hover:scale-110"
          phx-click={
            JS.toggle(
              to: "#faq-answer-#{@id}",
              in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
              out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
            )
            |> JS.toggle(to: "#faq-answer-toggle-show-#{@id}")
            |> JS.toggle(to: "#faq-answer-toggle-hide-#{@id}")
          }
        >
          <span id={"faq-answer-toggle-show-#{@id}"}>+</span>
          <span id={"faq-answer-toggle-hide-#{@id}"} style="display: none;">-</span>
        </button>
      </div>
    </div>
    """
  end
end
