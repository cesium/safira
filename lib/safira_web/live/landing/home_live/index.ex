defmodule SafiraWeb.Landing.HomeLive.Index do
  alias Safira.Companies
  use SafiraWeb, :landing_view

  import SafiraWeb.Landing.HomeLive.Components.{Hero, Partners, Pitch, Sponsors, Speakers}
  import SafiraWeb.Landing.Components.Schedule

  alias Safira.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Enum.take_random(Activities.list_highlighted_speakers(), 6)

    {:ok,
     socket
     |> assign(:tiers, Companies.list_tiers_with_companies())
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:has_highlighted_speakers?, speakers != [])
     |> assign(:registrations_open?, Event.registrations_open?())
     |> assign(:has_sponsors?, Companies.get_companies_count() > 0)
     |> assign(:has_schedule?, Activities.get_activities_count() > 0)
     |> assign(:enrolments, get_enrolments(socket.assigns.current_user))
     |> assign(:user_role, get_user_role(socket.assigns.current_user))
     |> stream(:speakers, speakers |> Enum.shuffle())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end

  @impl true
  def handle_event("enrol", %{"activity_id" => activity_id}, socket) do
    if is_nil(socket.assigns.current_user) do
      {:noreply,
       socket
       |> put_flash(:error, gettext("You must be logged in to enrol in activities"))
       |> redirect(to: ~p"/users/log_in?action=enrol&action_id=#{activity_id}")}
    else
      if socket.assigns.current_user.type == :attendee do
        actual_enrol(activity_id, socket)
      else
        {:noreply,
         socket
         |> put_flash(:error, gettext("Only attendees can enrol in activities"))}
      end
    end
  end

  defp get_enrolments(user) do
    if is_nil(user) or user.type != :attendee do
      []
    else
      Activities.get_attendee_enrolments(user.attendee.id)
    end
  end

  defp actual_enrol(activity_id, socket) do
    case Activities.enrol(socket.assigns.current_user.attendee.id, activity_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Successfully enrolled"))}

      {:error, _} ->
        {:noreplu,
         socket
         |> put_flash(:error, gettext("Something happened"))}
    end
  end

  defp get_user_role(user) do
    if is_nil(user) do
      :attendee
    else
      user.type
    end
  end
end
