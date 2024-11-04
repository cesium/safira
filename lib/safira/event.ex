defmodule Safira.Event do
  @moduledoc """
  The event context.
  """
  alias Safira.Constants

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

  defp ensure_date(string) when is_binary(string), do: Date.from_iso8601(string)

  defp ensure_date(date), do: date
end
