defmodule SafiraWeb.Backoffice.ScheduleLive.SpeakerLive.Index do
  use SafiraWeb, :live_component

  alias Safira.Activities
  alias Safira.Uploaders

  import SafiraWeb.Components.{EnsurePermissions, Table, TableSearch}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"schedule" => ["edit"]}}>
            <.link navigate={~p"/dashboard/schedule/activities/speakers/new"}>
              <.button>New Speaker</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <div class="pt-4 flex flex-col gap-2 h-[30.5rem]">
          <.table_search
            id="speaker-table-name-search"
            params={@params}
            field={:name}
            path={~p"/dashboard/schedule/activities/speakers"}
            placeholder={gettext("Search for speakers")}
            class="w-full"
          />
          <.table id="speakers-table" items={@streams.speakers} meta={@meta} params={@params}>
            <:col :let={{_id, speaker}} sortable field={:name} label="Name">
              <div class="flex gap-4 flex-center items-center">
                <%= if speaker.picture do %>
                  <img
                    class="rounded-full h-10"
                    src={Uploaders.Speaker.url({speaker.picture, speaker}, :original, signed: true)}
                  />
                <% else %>
                  <.avatar handle={speaker.name} />
                <% end %>
                <div class="self-center">
                  <p class="text-base font-semibold"><%= speaker.name %></p>
                  <p class="font-normal"><%= speaker.title %></p>
                </div>
              </div>
            </:col>
            <:col :let={{_id, speaker}} sortable field={:company} label="Company">
              <%= speaker.company %>
            </:col>
            <:action :let={{id, speaker}}>
              <.ensure_permissions user={@current_user} permissions={%{"schedule" => ["edit"]}}>
                <div class="flex flex-row gap-2">
                  <.link patch={~p"/dashboard/schedule/activities/speakers/#{speaker.id}/edit"}>
                    <.icon name="hero-pencil" class="w-5 h-5" />
                  </.link>
                  <.link
                    phx-click={
                      JS.push("delete", value: %{id: speaker.id}, target: @myself) |> hide("##{id}")
                    }
                    data-confirm="Are you sure?"
                  >
                    <.icon name="hero-trash" class="w-5 h-5" />
                  </.link>
                </div>
              </.ensure_permissions>
            </:action>
          </.table>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    speaker = Activities.get_speaker!(id)
    {:ok, _} = Activities.delete_speaker(speaker)

    {:noreply, stream_delete(socket, :speakers, speaker)}
  end
end
