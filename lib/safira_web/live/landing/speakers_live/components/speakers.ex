defmodule SafiraWeb.Landing.SpeakersLive.Components.Speakers do
  @moduledoc """
  Speakers component.
  """
  use SafiraWeb, :component

  alias Plug.Conn.Query
  alias Safira.Activities

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :url, :string, required: true
  attr :params, :map, required: true
  attr :has_filters?, :boolean, default: false
  attr :descriptions_enabled, :boolean, default: false

  def speakers(assigns) do
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
        </div>
      </div>
      <div>
        <.schedule_table
          date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
          filters={fetch_filters_from_params(assigns.params)}
          descriptions_enabled={assigns.descriptions_enabled}
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
      <%= for %{speaker: speaker, activity: activity} <- Activities.list_daily_speakers(@date) do %>
        <.speaker speaker={speaker} activity={activity} />
      <% end %>
    </div>
    """
  end

  defp speaker(assigns) do
    ~H"""
    <div class="border-t-2 border-white py-4 text-white transition-all">
      <div class="mb-2 flex">
        <div class="w-[210px] select-none">
          <img
            alt="Marcelo Pereira"
            loading="lazy"
            width="210"
            height="210"
            decoding="async"
            data-nimg="1"
            style="color: transparent; width: 100%; height: auto;"
            sizes="100vw"
            src={
              if @speaker.picture do
                Uploaders.Speaker.url({@speaker.picture, @speaker}, :original, signed: true)
              else
                "https://github.com/identicons/#{@speaker.name |> String.slice(0..2)}.png"
              end
            }
          />
        </div>
        <div class="ml-4 flex w-full flex-col justify-between">
          <div class="flex justify-between">
            <div>
              <h2 class="font-terminal-uppercase text-xl"><%= @speaker.name %></h2>
              <p class=""><%= @speaker.title %></p>
              <p class=""><%= @speaker.company %></p>
            </div>
            <div class="ml-4 flex gap-2">
              <.social platform="github" profile={@speaker.socials.github} />
              <.social platform="linkedin" profile={@speaker.socials.linkedin} />
              <.social platform="website" profile={@speaker.socials.website} />
              <.social platform="x" profile={@speaker.socials.x} />
            </div>
          </div>
          <div
            id={"speaker-#{@speaker.id}-#{@activity.id}"}
            class="overflow-hidden pb-4 mt-8"
            style="display: none;"
          >
            <p><%= @speaker.biography %></p>
          </div>
          <div class="z-50 flex select-none items-center justify-end">
            <p class="w-28 grow text-gray-400">
              <%= @activity.title %> <%= format_time(@activity.time_start) %>
            </p>
            <button
              class="ml-4 w-16 rounded-full border border-gray-500 px-2 font-iextrabold text-xl text-white transition-colors hover:bg-white/20"
              phx-click={
                JS.toggle(
                  to: "#speaker-#{@speaker.id}-#{@activity.id}",
                  in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
                  out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
                )
                |> JS.toggle(to: "#speaker-toggle-show-#{@speaker.id}-#{@activity.id}")
                |> JS.toggle(to: "#speaker-toggle-hide-#{@speaker.id}-#{@activity.id}")
              }
            >
              <span id={"speaker-toggle-show-#{@speaker.id}-#{@activity.id}"}>+</span>
              <span id={"speaker-toggle-hide-#{@speaker.id}-#{@activity.id}"} style="display: none;">
                -
              </span>
            </button>
          </div>
        </div>
      </div>
      <div>
        <p class="transition-max-height overflow-hidden duration-300 max-h-0">
          <%= @speaker.biography %>
        </p>
      </div>
    </div>
    """
  end

  defp social(assigns) do
    {icon, url} =
      case assigns.platform do
        "github" -> {"fa-brand-github", "https://github.com/#{assigns.profile}"}
        "linkedin" -> {"fa-brand-linkedin", "https://linkedin.com/in/#{assigns.profile}"}
        "x" -> {"fa-brand-twitter", "https://x.com/#{assigns.profile}"}
        "website" -> {"hero-globe-alt", assigns.profile}
      end

    ~H"""
    <.link :if={not is_nil(@profile)} href={url} target="_blank">
      <.icon name={icon} class="h-5 w-5" />
    </.link>
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

  defp format_time(time) do
    hour = if time.hour < 10, do: "0#{time.hour}", else: "#{time.hour}"
    minute = if time.minute < 10, do: "0#{time.minute}", else: "#{time.minute}"
    "#{hour}:#{minute}"
  end

  defp toggle_filter(filters, category_id) do
    if Enum.member?(filters, category_id) do
      List.delete(filters, category_id)
    else
      filters ++ [category_id]
    end
  end

  defp fetch_categories do
    Activities.list_activity_categories()
  end
end
