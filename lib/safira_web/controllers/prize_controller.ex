defmodule SafiraWeb.PrizeController do
  use SafiraWeb, :controller

  alias Safira.Roulette

  def index(conn, _params) do
    prizes = Roulette.list_prizes()
    render(conn, "index.json", prizes: prizes)
  end

  def show(conn, %{"id" => id}) do
    prize = Roulette.get_prize!(id)
    render(conn, "show.json", prize: prize)
  end

end
