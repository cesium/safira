defmodule SafiraWeb.Components.SearchBar do
  @moduledoc """
  Search bar component.
  """
  use SafiraWeb, :component

  def search_bar(assigns) do
    ~H"""
    <div class="flex items-center bg-light/5 rounded-4xl px-3 border border-warning-400">
      <form phx-change="update-search">
        <span class="hero-magnifying-glass h-5 w-5"></span>
        <input
          type="text"
          placeholder="Search for badges"
          name="badge_search"
          class="bg-transparent border-none focus:outline-none focus:ring-0 focus:border-none w-fit font-terminal"
        />
      </form>
    </div>
    """
  end
end
