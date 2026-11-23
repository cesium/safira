defmodule SafiraWeb.Landing.HomeLive.Components.Hero do
  @moduledoc false
  use SafiraWeb, :component

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true

  def hero(assigns) do
    ~H"""
    <section
      id="hero"
      class="relative flex min-h-dvh snap-start flex-col justify-center overflow-x-clip px-10 md:px-15"
    >
      <div class="flex select-none flex-col gap-8 text-white animate-slide-in">
        <h1 class="font-pixel text-5xl leading-tight md:text-6xl lg:text-7xl">
          Semana da<br /> Engenharia<br /> Informática<br />
          <span class="font-pixel-grid opacity-70">{@event_start_date.year}</span>
        </h1>

        <p class="font-mono text-lg lg:text-xl">
          {display_event_dates(@event_start_date, @event_end_date)}
        </p>
      </div>

      <img
        src={~p"/images/void.svg"}
        alt="void"
        class="pointer-events-none absolute right-0 hidden w-1/2 lg:w-2/5 translate-x-1/4 select-none sm:block animate-slide-in"
      />
    </section>
    """
  end

  defp display_event_dates(event_start_date, event_end_date) do
    "#{Timex.format!(event_start_date, "{D}")}-#{Timex.format!(event_end_date, "{D} {Mfull} {YYYY}")}"
  end
end
