defmodule SafiraWeb.Landing.Components.Schedule do
  @moduledoc """
  Schedule component.
  """
  use SafiraWeb, :live_component

  alias Plug.Conn.Query
  alias Safira.Activities

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(enrolments: get_enrolments(assigns.current_user))}
  end

  @impl true
  def render(assigns) do
    current_day =
      get_day(
        fetch_current_date_from_params(assigns.params),
        assigns.event_start_date,
        assigns.event_end_date
      )

    ~H"""
    <div class="xl:grid 2xl:grid-cols-2 gap-8 relative select-none">
      <div class="mb-20 2xl:mb-0">
        <div class="sticky top-12">
          <.schedule_day
            date={current_day}
            url={@url}
            params={@params}
            filters={fetch_filters_from_params(assigns.params)}
            event_start_date={@event_start_date}
            event_end_date={@event_end_date}
          />
          <.filters
            :if={@has_filters?}
            url={@url}
            current_day={current_day}
            filters={fetch_filters_from_params(assigns.params)}
          />
        </div>
      </div>
      <div>
        <.schedule_table
          date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
          filters={fetch_filters_from_params(assigns.params)}
          user_role={get_user_role(assigns.current_user)}
          enrolments={assigns.enrolments}
          myself={assigns.myself}
        />
      </div>
    </div>
    """
  end

  defp filters(assigns) do
    ~H"""
    <div class="block relative mt-8">
      <span class="w-full font-iregular text-lg uppercase"><%= gettext("Filter by") %></span>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 pt-4">
        <%= for category <- fetch_categories() do %>
          <.link
            class={
              if Enum.member?(@filters, category.id),
                do:
                  "text-md m-1 items-center rounded-full border-2 px-12 py-2 text-center font-bold text-accent border-accent shadow-sm hover:opacity-60",
                else:
                  "text-md m-1 items-center rounded-full border-2 py-2 text-center font-bold text-white shadow-sm hover:bg-white/20 px-8 transition-colors"
            }
            patch={filter_url(@url, @current_day, @filters, category.id)}
          >
            <%= category.name %>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  defp schedule_table(assigns) do
    ~H"""
    <div>
      <%= for activity_section <- fetch_daily_activities(@date, @filters) do %>
        <div class="flex lg:flex-row flex-col sm:w-full">
          <%= for activity <- activity_section do %>
            <%= if activity.category && activity.category.name == "Break" do %>
              <.schedule_break activity={activity} />
            <% else %>
              <.schedule_activity
                activity={activity}
                user_role={@user_role}
                enrolments={@enrolments}
                myself={@myself}
              />
            <% end %>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp schedule_activity(assigns) do
    ~H"""
    <div id={@activity.id} class="mx-2 sm:w-full border-t border-white p-[10px] ml-[10px] relative">
      <div class="relative h-full">
        <!-- Times -->
        <p class="text-lg font-iregular font-bold text-white xs:text-xl">
          <%= "#{@activity.time_start |> Timex.format!("{h24}:{m}")} - #{@activity.time_end |> Timex.format!("{h24}:{m}")}" %>
        </p>
        <!-- Title -->
        <p class="font-iregular text-xl text-white">
          <span :if={@activity.category} class="font-iregular font-bold">
            <%= @activity.category.name %>
          </span>
          <span class={!@activity.category && "font-bold"}>
            <%= @activity.title %>
          </span>
        </p>
        <!-- Speakers -->
        <ul class="my-[0.4em] flex font-iregular text-sm text-gray-400 z-10 gap-2 xl:gap-0">
          <li
            :for={{speaker, index} <- Enum.with_index(@activity.speakers, fn el, i -> {el, i} end)}
            class="list-none xl:float-left"
          >
            <%= if index == length(@activity.speakers) - 1 and length(@activity.speakers) != 1 do %>
              <bdi class="ml-[5px] hidden xl:inline">
                <%= gettext("and") %>
              </bdi>
            <% else %>
              <span class="hidden xl:inline">
                <%= if index != 0, do: "," %>
              </span>
            <% end %>
            <!-- Must be an <a> tag as to force page to reload completely so the #id rerouting works -->
            <a
              href={"/speakers?date=#{@activity.date}&speaker_id=#{speaker.id}#sp-#{speaker.id}-#{@activity.id}"}
              class="my-[0.4em] hover:underline"
            >
              <%= speaker.name %>
            </a>
          </li>
        </ul>

        <p id={"schedule-#{@activity.id}"} class="overflow-hidden pb-4" style="display: none;">
          <%= @activity.description %>
        </p>
        <!-- Spacing -->
        <div class="h-20 w-2"></div>

        <div class="absolute bottom-0 mt-auto w-full py-3">
          <div class="flex flex-wrap justify-center">
            <!-- Location -->
            <div class="flex w-auto items-center">
              <p class="float-right font-iregular text-sm text-gray-400">
                <%= @activity.location %>
              </p>
            </div>
            <!-- Enrol -->
            <div class="float-right mr-5 flex flex-1 items-center justify-end">
              <p
                :if={enrolments_enabled(@activity, @user_role, @enrolments)}
                class="relative hover:underline cursor-pointer -mr-3 font-iregular text-lg text-accent sm:mr-1"
                phx-click="enrol"
                phx-target={@myself}
                data-confirm={"#{gettext("You are enrolling for")} #{@activity.title}. #{gettext("This action cannot be undone. Are you sure?")}"}
                phx-value-activity_id={@activity.id}
              >
                <%= gettext("Enrol") %>
              </p>
              <p
                :if={already_enrolled(@activity, @enrolments)}
                class="relative -mr-3 font-iregular text-lg text-accent sm:mr-1"
                phx-value-activity_id={@activity.id}
              >
                <%= gettext("Enrolled") %>
              </p>
            </div>
            <!-- Expand -->
            <button
              :if={not is_nil(@activity.description) and @activity.description != ""}
              class="font-terminal uppercase w-16 select-none rounded-full px-2 text-xl text-white border border-white hover:bg-white/20 transition-colors"
              phx-click={
                JS.toggle(
                  to: "#schedule-#{@activity.id}",
                  in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
                  out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
                )
                |> JS.toggle(to: "#schedule-toggle-show-#{@activity.id}")
                |> JS.toggle(to: "#schedule-toggle-hide-#{@activity.id}")
              }
            >
              <span id={"schedule-toggle-show-#{@activity.id}"}>+</span>
              <span id={"schedule-toggle-hide-#{@activity.id}"} style="display: none;">-</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp schedule_break(assigns) do
    ~H"""
    <div id={@activity.id} class="mx-2 sm:w-full border-t border-white p-[10px] ml-[10px] relative">
      <div class="relative h-full flex flex-row justify-between items-center">
        <p class="font-iregular text-xl text-white font-bold">
          <%= @activity.title %>
        </p>
        <div>
          <%= if (@activity.title |> String.downcase() |> String.contains?("lunch")) do %>
            <img src={~p"/images/breaks/lunch.svg"} class="w-8 h-8" />
          <% else %>
            <img src={~p"/images/breaks/coffee.svg"} class="w-8 h-8" />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp schedule_day(assigns) do
    ~H"""
    <div class="flex sm:w-full select-none justify-center">
      <div class="flex w-full justify-between text-4xl xs:text-5xl sm:text-7xl lg:text-8xl xl:mx-20 xl:text-7xl">
        <div class="right relative flex items-center justify-center mt-[0.15em]">
          <.link
            :if={Date.compare(@date, @event_start_date) in [:gt]}
            class="cursor-pointer"
            patch={day_url(@url, @date, -1, @filters)}
          >
            <.left_arrow />
          </.link>
        </div>

        <div class="-mt-8 md:-mt-10">
          <h5 class="font-terminal uppercase text-2xl text-accent md:text-3xl">
            <%= @date |> Timex.format!("{D} {Mshort}") %>
          </h5>
          <h2 class="font-terminal uppercase">
            <%= @date |> Timex.format!("{WDfull}") %>
          </h2>
        </div>

        <div class="left relative flex items-center justify-center mt-[0.15em]">
          <.link
            :if={Date.compare(@date, @event_end_date) in [:lt]}
            class="cursor-pointer"
            patch={day_url(@url, @date, 1, @filters)}
          >
            <.right_arrow />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp right_arrow(assigns) do
    ~H"""
    <svg
      class="h-[0.8em] w-[0.8em] fill-transparent transition-all hover:fill-white"
      width="42"
      height="65"
      viewBox="0 0 42 65"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d)">
        <path
          d="M23.4299 28.0481L5.02799 7.62693L12.4568 0.932693L37.1704 28.3582L12.5527 55.8698L5.10057 49.2016L23.4311 28.7162L23.7304 28.3817L23.4299 28.0481Z"
          stroke="white"
        />
      </g>
      <defs>
        <filter
          id="filter0_d"
          x="0.309082"
          y="0.182373"
          width="41.5826"
          height="64.4078"
          filterUnits="userSpaceOnUse"
          color-interpolation-filters="sRGB"
        >
          <feFlood flood-opacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          />
          <feOffset dy="4" />
          <feGaussianBlur stdDeviation="2" />
          <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0" />
          <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
          <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
        </filter>
      </defs>
    </svg>
    """
  end

  defp left_arrow(assigns) do
    ~H"""
    <svg
      class="h-[0.8em] w-[0.8em] fill-transparent transition-all hover:fill-white"
      width="42"
      height="65"
      viewBox="0 0 42 65"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d)">
        <path
          d="M37.3861 49.2873L29.9456 55.9686L5.27991 28.5L29.9456 1.03139L37.3861 7.71264L19.0199 28.1659L18.7199 28.5L19.0199 28.8341L37.3861 49.2873Z"
          stroke="white"
        />
      </g>
      <defs>
        <filter
          id="filter0_d"
          x="0.60791"
          y="0.325317"
          width="41.4843"
          height="64.3494"
          filterUnits="userSpaceOnUse"
          color-interpolation-filters="sRGB"
        >
          <feFlood flood-opacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          />
          <feOffset dy="4" />
          <feGaussianBlur stdDeviation="2" />
          <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0" />
          <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
          <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
        </filter>
      </defs>
    </svg>
    """
  end

  @impl true
  def handle_event("enrol", %{"activity_id" => activity_id}, socket) do
    if is_nil(socket.assigns.current_user) do
      {:noreply,
       socket
       |> put_flash(:error, gettext("You must be logged in to enrol in activities"))
       |> redirect(to: ~p"/users/log_in?action=enrol&action_id=#{activity_id}&return_to=/")}
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

  defp actual_enrol(activity_id, socket) do
    case Activities.enrol(socket.assigns.current_user.attendee.id, activity_id) do
      {:ok, _} ->
        send(self(), {:update_flash, {:info, gettext("Successfully enrolled")}})

        {:noreply,
         socket
         |> assign(
           :enrolments,
           Activities.get_attendee_enrolments(socket.assigns.current_user.attendee.id)
         )}

      {:error, _} ->
        send(self(), {:update_flash, {:info, gettext("Unable to enrol")}})
        {:noreply, socket}
    end
  end

  defp get_enrolments(user) do
    if is_nil(user) or user.type != :attendee do
      []
    else
      Activities.get_attendee_enrolments(user.attendee.id)
    end
  end

  defp get_user_role(user) do
    if is_nil(user) do
      :attendee
    else
      user.type
    end
  end

  defp fetch_current_date_from_params(params) do
    case Map.get(params, "date") do
      nil ->
        nil

      day ->
        case Date.from_iso8601(day) do
          {:ok, date} -> date
          _ -> nil
        end
    end
  end

  defp get_day(params_date, start_date, end_date) do
    now = Date.utc_today()

    cond do
      not is_nil(params_date) ->
        params_date

      Date.compare(now, start_date) == :lt ->
        start_date

      Date.compare(now, end_date) == :gt ->
        end_date

      true ->
        now
    end
  end

  defp fetch_filters_from_params(params) do
    Map.get(params, "filters", [])
  end

  defp day_url(url, current_day, shift, filters) do
    query = %{"date" => Timex.shift(current_day, days: shift), "filters" => filters}

    "#{url}?#{Query.encode(query)}"
  end

  defp filter_url(url, current_day, filters, category_id) do
    new_filters = toggle_filter(filters, category_id)
    query = %{"date" => current_day, "filters" => new_filters}

    "#{url}?#{Query.encode(query)}"
  end

  defp toggle_filter(filters, category_id) do
    if Enum.member?(filters, category_id) do
      List.delete(filters, category_id)
    else
      filters ++ [category_id]
    end
  end

  defp fetch_daily_activities(day, filters) do
    Activities.list_daily_activities(day)
    |> Enum.filter(fn at -> filters == [] or at.category_id in filters end)
    |> group_activities()
  end

  defp fetch_categories do
    Activities.list_activity_categories()
  end

  defp group_activities(activities) do
    Enum.reduce(activities, [], fn activity, acc ->
      case acc do
        [] ->
          [[activity]]

        [[head | tail] | rest] = grouped ->
          if activity.time_start == head.time_start do
            [[activity, head | tail] | rest]
          else
            [[activity] | grouped]
          end
      end
    end)
    |> Enum.reverse()
  end

  defp already_enrolled(activity, enrolments) do
    Enum.member?(Enum.map(enrolments, & &1.activity_id), activity.id)
  end

  defp enrolments_enabled(activity, user_role, enrolments) do
    not_full = activity.max_enrolments > activity.enrolment_count
    is_staff = user_role == :staff

    enrolled_at_same_time =
      Enum.any?(enrolments, fn e ->
        Time.compare(e.activity.time_start, activity.time_end) == :lt and
          Time.compare(e.activity.time_end, activity.time_start) == :gt and
          e.activity.date == activity.date
      end)

    not_full and activity.has_enrolments and not enrolled_at_same_time and not is_staff
  end
end
