defmodule SafiraWeb.Backoffice.SpotlightLive.FormComponent do
    use SafiraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
      >
        <h1><%= @title %></h1>
      </.page>
    </div>
    """
  end



end
