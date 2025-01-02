defmodule Safira.Event do
  @moduledoc """
  The event context.
  """
  alias Safira.Constants

  @pubsub Safira.PubSub

  @doc """
  Returns whether the registrations for the event are open

  ## Examples

      iex> registrations_open?()
      false
  """
  def registrations_open? do
    case Constants.get("registrations_open") do
      {:ok, registrations_open} ->
        case String.downcase(registrations_open) do
          "true" -> true
          _ -> false
        end

      _ ->
        false
    end
  end

  def change_registrations_open(registrations_open) do
    Constants.set(
      "registrations_open",
      if registrations_open do
        "true"
      else
        "false"
      end
    )
  end

  def get_event_start_time! do
    with {:ok, start_time_str} <- Constants.get("start_time") do
      with {:ok, start_time, _} <- DateTime.from_iso8601(start_time_str) do
        start_time
      end
    end
  end

  def change_event_start_time(start_time) do
    result = Constants.set("start_time", DateTime.to_iso8601(start_time))
    broadcast_start_time_update("start_time", start_time)
    result
  end

  @doc """
  Subscribes the caller to the start time's updates.

  ## Examples

      iex> subscribe_to_start_time_update("start_time")
      :ok
  """
  def subscribe_to_start_time_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, config)
  end

  defp broadcast_start_time_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, "start_time", {config, value})
  end

  def event_started? do
    start_time = get_event_start_time!()
    DateTime.compare(start_time, DateTime.utc_now()) == :lt
  end

  @doc """
  Returns the event's start date.
  If the date is not set, it will be set to today's date by default.

  ## Examples

      iex> get_event_start_date()
      ~D[2025-02-11]
  """
  def get_event_start_date do
    case Constants.get("event_start_date") do
      {:ok, date} ->
        ensure_date(date)

      {:error, _} ->
        # If the date is not set, set it to today's date by default
        today = Timex.today()
        change_event_start_date(today)
        today
    end
  end

  @doc """
  Returns the event's end date.
  If the date is not set, it will be set to today's date by default.

  ## Examples

      iex> get_event_end_date()
      ~D[2025-02-14]
  """
  def get_event_end_date do
    case Constants.get("event_end_date") do
      {:ok, date} ->
        ensure_date(date)

      {:error, _} ->
        # If the date is not set, set it to today's date by default
        today = Timex.today()
        change_event_end_date(today)
        today
    end
  end

  @doc """
  Changes the event's start date.

  ## Examples

      iex> change_event_start_date(~D[2025-02-11])
      :ok
  """
  def change_event_start_date(date) do
    Constants.set("event_start_date", date)
  end

  @doc """
  Changes the event's end date.

  ## Examples

      iex> change_event_end_date(~D[2025-02-14])
      :ok
  """
  def change_event_end_date(date) do
    Constants.set("event_end_date", date)
  end

  defp ensure_date(string) when is_binary(string), do: Date.from_iso8601!(string)

  defp ensure_date(date), do: date
end
