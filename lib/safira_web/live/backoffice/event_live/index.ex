defmodule SafiraWeb.Backoffice.EventLive.Index do
  use SafiraWeb, :backoffice_view

  alias Safira.Event
  alias Safira.Event.Faq
  alias Safira.Teams

  on_mount {SafiraWeb.StaffRoles,
            show: %{"event" => ["show"]},
            edit: %{"event" => ["edit"]},
            faqs_edit: %{"event" => ["edit_faqs"]},
            faqs_new: %{"event" => ["edit_faqs"]}}

  @impl true
  def mount(_params, _session, socket) do
    registrations_open = Event.registrations_open?()
    start_time = Event.get_event_start_time!()
    feature_flags = Event.get_feature_flags()

    form =
      %{"registrations_open" => registrations_open, "start_time" => start_time}
      |> Map.merge(feature_flags)
      |> to_form()

    {:ok,
     socket
     |> assign(:current_page, :event)
     |> assign(form: form)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Event Settings")
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Event Settings")
  end

  defp apply_action(socket, :faqs, _params) do
    socket
    |> assign(:page_title, "List FAQs")
  end

  defp apply_action(socket, :faqs_edit, %{"id" => faq_id}) do
    socket
    |> assign(:page_title, "Edit FAQ")
    |> assign(:faq, Event.get_faq!(faq_id))
  end

  defp apply_action(socket, :faqs_new, _params) do
    socket
    |> assign(:page_title, "New FAQ")
    |> assign(:faq, %Faq{})
  end

  defp apply_action(socket, :teams, _params) do
    socket
    |> assign(:page_title, "Teams")
  end

  defp apply_action(socket, :teams_new, _params) do
    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, %Teams.Team{})
  end

  defp apply_action(socket, :teams_edit, %{"team_id" => team_id}) do
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:team, Teams.get_team!(team_id))
  end

  defp apply_action(socket, :teams_members, %{"team_id" => team_id}) do
    socket
    |> assign(:page_title, "New Team Member")
    |> assign(:team, Teams.get_team!(team_id))
    |> assign(:members, Teams.list_team_members(team_id))
    |> assign(:member, %Teams.TeamMember{})
  end

  defp apply_action(socket, :teams_members_edit, %{"id" => member_id}) do
    case Teams.get_team_member!(member_id) do
      nil ->
        socket
        |> put_flash(:error, "Team member not found")
        |> push_patch(to: socket.assigns.patch)

      member ->
        socket
        |> assign(:page_title, "Edit Team Member")
        |> assign(:team, member.team)
        |> assign(:member, member)
    end
  end

  defp apply_action(socket, :credentials, _params) do
    socket
    |> assign(:page_title, "Generate Credentials")
  end
end
