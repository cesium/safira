defmodule SafiraWeb.Landing.Components.Schedule do
  @moduledoc """
  Schedule component.
  """
  use SafiraWeb, :component

  alias Plug.Conn.Query
  alias Safira.Activities

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :url, :string, required: true
  attr :params, :map, required: true
  attr :has_filters?, :boolean, default: false

  def schedule(assigns) do
    ~H"""
    <div class="xl:grid 2xl:grid-cols-2 gap-8 relative select-none">
      <div class="mb-20 2xl:mb-0">
        <div class="sticky top-12">
          <.schedule_day
            date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
            url={@url}
            params={@params}
            filters={fetch_filters_from_params(assigns.params)}
            event_start_date={@event_start_date}
            event_end_date={@event_end_date}
          />
          <.filters
            :if={@has_filters?}
            url={@url}
            current_day={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
            filters={fetch_filters_from_params(assigns.params)}
          />
        </div>
      </div>
      <div>
        <.schedule_table
          date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
          filters={fetch_filters_from_params(assigns.params)}
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
                do: "text-md m-1 items-center rounded-full border-2 px-12 py-2 text-center font-bold
                                  text-accent border-accent shadow-sm
                                hover:opacity-60
                                ",
                else: "text-md m-1 items-center rounded-full border-2 px-12 py-2 text-center font-bold
                                  text-white shadow-sm
                                hover:border-accent hover:text-accent px-8
                                "
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
              <.schedule_activity activity={activity} />
            <% end %>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp schedule_activity(assigns) do
    ~H"""
    <div
      id={@activity.id}
      class="mx-2 sm:w-full border-t border-white p-[10px] ml-[10px] relative hover:bg-white/10 transition-colors"
    >
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
        <ul class="my-[0.4em] flex font-iregular text-sm text-gray-400 z-10 gap-2 sm:gap-0">
          <li
            :for={{speaker, index} <- Enum.with_index(@activity.speakers, fn el, i -> {el, i} end)}
            class="list-none sm:float-left"
          >
            <%= if index == length(@activity.speakers) - 1 and length(@activity.speakers) != 1 do %>
              <bdi class="ml-[5px] hidden sm:inline">
                <%= gettext("and") %>
              </bdi>
            <% else %>
              <span class="hidden sm:inline">
                <%= if index != 0, do: "," %>
              </span>
            <% end %>
            <.link navigate={~p"/"} class="my-[0.4em] hover:underline">
              <%= speaker.name %>
            </.link>
          </li>
        </ul>
        <!-- Spacing -->
        <div class="h-20 w-2"></div>

        <div class="absolute bottom-0 mt-auto sm:w-full py-3">
          <div class="flex flex-wrap justify-center">
            <!-- Location -->
            <div class="flex w-auto items-center">
              <p class="float-right font-iregular text-sm text-gray-400">
                <%= @activity.location %>
              </p>
            </div>
            <!-- Enroll -->
            <div class="float-right mr-5 flex flex-1 items-center justify-end">
              <p
                :if={@activity.has_enrolments}
                class="relative hover:underline cursor-pointer -mr-3 font-iregular text-lg text-accent sm:mr-1"
              >
                <%= gettext("Enroll") %>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp schedule_break(assigns) do
    ~H"""
    <div
      id={@activity.id}
      class="mx-2 sm:w-full border-t border-white p-[10px] ml-[10px] relative hover:bg-white/10 transition-colors"
    >
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
      <div class="flex sm:w-full justify-between text-4xl xs:text-5xl sm:text-7xl lg:text-8xl xl:mx-20 xl:text-7xl">
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
    |> Enum.group_by(& &1.time_start)
    |> Enum.map(&elem(&1, 1))
  end

  defp fetch_categories do
    Activities.list_activity_categories()
  end
end
