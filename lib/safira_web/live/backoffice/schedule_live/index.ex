defmodule SafiraWeb.Backoffice.ScheduleLive.Index do
  alias Safira.Activities.Speaker
  use SafiraWeb, :backoffice_view

  import SafiraWeb.Components.{Table, TableSearch}

  alias Safira.Activities
  alias Safira.Activities.{Activity, ActivityCategory, Speaker}

  on_mount {SafiraWeb.StaffRoles, index: %{"schedule" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Activities.list_activities(
           if socket.assigns.live_action != :speakers do
             params
           else
             %{}
           end,
           preloads: [:category]
         ) do
      {:ok, {activities, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :schedule)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:activities, activities, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity")
    |> assign(:activity, Activities.get_activity!(id))
    |> assign(:categories, Activities.list_activity_categories())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Activity")
    |> assign(:activity, %Activity{speakers: []})
    |> assign(:categories, Activities.list_activity_categories())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activities")
  end

  defp apply_action(socket, :categories_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Activities.get_activity_category!(id))
  end

  defp apply_action(socket, :categories_new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %ActivityCategory{})
  end

  defp apply_action(socket, :categories, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
  end

  defp apply_action(socket, :speakers_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Speaker")
    |> assign(:speaker, Activities.get_speaker!(id))
  end

  defp apply_action(socket, :speakers_new, _params) do
    socket
    |> assign(:page_title, "New Speaker")
    |> assign(:speaker, %Speaker{})
  end

  defp apply_action(socket, :speakers, params) do
    case Activities.list_speakers(params) do
      {:ok, {speakers, meta}} ->
        socket
        |> assign(:page_title, "Listing Speakers")
        |> assign(:speakers_meta, meta)
        |> assign(:params, params)
        |> stream(:speakers, speakers, reset: true)

      {:error, _} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity = Activities.get_activity!(id)

    {:ok, _} = Activities.delete_activity(activity)

    {:noreply, stream_delete(socket, :activities, activity)}
  end

  defp formatted_activity_times(activity) do
    format = "{h24}:{m}"

    "#{activity.time_start |> Timex.format!(format)} - #{activity.time_end |> Timex.format!(format)}"
  end
end
