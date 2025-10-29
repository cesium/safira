defmodule SafiraWeb.Backoffice.EventLive.FaqLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Event
  import SafiraWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"event" => ["edit_faqs"]}}>
            <.link navigate={~p"/dashboard/event/faqs/new"}>
              <.button>New FAQ</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <ul class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto">
          <li
            :for={{id, faq} <- @streams.faqs}
            id={id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 px-4 py-4 flex flex-row w-full justify-between"
          >
            <p>{faq.question}</p>
            <.ensure_permissions user={@current_user} permissions={%{"event" => ["edit_faqs"]}}>
              <.link patch={~p"/dashboard/event/faqs/#{faq.id}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
            </.ensure_permissions>
          </li>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:faqs, Event.list_faqs())}
  end
end
