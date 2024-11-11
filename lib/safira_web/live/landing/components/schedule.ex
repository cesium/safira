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

  def schedule(assigns) do
    ~H"""
    <div class="px-5 md:px-32 xl:grid xl:grid-cols-2 xl:px-16 2xl:px-32 relative select-none pt-20">
      <div class="mb-20 xl:mb-0">
        <div class="sticky top-12">
          <.schedule_day
            date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
            url={@url}
            params={@params}
            event_start_date={@event_start_date}
            event_end_date={@event_end_date}
          />
        </div>
      </div>
      <div>
        <.schedule_table date={
          fetch_current_date_from_params(assigns.params) || assigns.event_start_date
        } />
      </div>
    </div>
    """
  end

  defp schedule_table(assigns) do
    ~H"""
    <div>
      <%= for activity <- fetch_daily_activities(@date) do %>
        <.schedule_activity activity={activity} />
      <% end %>
    </div>
    """
  end

  defp schedule_activity(assigns) do
    ~H"""
    <div id={@activity.id} class="mx-2 h-full border-t border-white p-[10px] ml-[10px] relative">
      <p class="text-lg font-iregular font-bold text-white xs:text-xl">
        <%= "#{@activity.time_start |> Timex.format!("{h24}:{m}")} - #{@activity.time_end |> Timex.format!("{h24}:{m}")}" %>
      </p>
      <p class="font-iregular text-xl text-white">
        <span :if={@activity.category} class="font-iregular font-bold">
          <%= @activity.category.name %>
        </span>
        <%= @activity.title %>
      </p>
    </div>
    """
  end

  defp schedule_day(assigns) do
    ~H"""
    <div class="flex w-full select-none justify-center">
      <div class="flex w-full justify-between text-4xl xs:text-5xl sm:text-7xl lg:text-8xl xl:mx-20 xl:text-7xl">
        <div class="right relative flex items-center justify-center mt-[0.15em]">
          <.link
            :if={Date.compare(@date, @event_start_date) in [:gt]}
            class="cursor-pointer"
            patch={day_url(@url, @date, -1)}
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
            patch={day_url(@url, @date, 1)}
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

  defp day_url(url, current_day, shift) do
    query = %{"date" => Timex.shift(current_day, days: shift)}

    "#{url}?#{Query.encode(query)}"
  end

  defp fetch_daily_activities(day) do
    Activities.list_daily_activities(day)
  end
end
