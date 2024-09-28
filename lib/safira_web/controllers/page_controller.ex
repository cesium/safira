defmodule SafiraWeb.PageController do
  use SafiraWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def countdown(conn, _params) do
    start_time = Application.fetch_env!(:safira, SafiraWeb.Endpoint)[:start_time]

    if(DateTime.compare(start_time, DateTime.utc_now()) == :lt) do
      conn
      |> redirect(to: ~p"/app")
    else
      render(conn |> assign(:start_time, start_time), :countdown, layout: false)
    end
  end
end
