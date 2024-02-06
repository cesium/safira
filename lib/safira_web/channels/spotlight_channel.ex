defmodule SafiraWeb.SpotlightChannel do
  use Phoenix.Channel

  alias Safira.Accounts
  alias Safira.Interaction

  def join("spotlight", _params, socket) do
    Phoenix.PubSub.subscribe(Safira.PubSub, "spotlight")
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    spotlight = Interaction.get_spotlight()
    company = Accounts.get_company_by_badge!(spotlight.badge_id)

    data = %{
      "id" => company.id,
      "name" => company.name,
      "badge_id" => company.badge_id,
      "end" => spotlight.end
    }

    push(socket, "spotlight", data)
    {:noreply, socket}
  end

  def handle_info(%{"spotlight" => body}, socket) do
    push(socket, "spotlight", body)
    {:noreply, socket}
  end
end
