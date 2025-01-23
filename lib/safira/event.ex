defmodule Safira.Event do
  @moduledoc """
  The event context.
  """
  use Safira.Context

  alias Safira.Constants
  alias Safira.Event.Faq

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

  defp bool_to_string(true), do: "true"
  defp bool_to_string(false), do: "false"

  def change_registrations_open(registrations_open) do
    Constants.set(
      "registrations_open",
      bool_to_string(registrations_open)
    )
  end

  def get_event_start_time! do
    case Constants.get("start_time") do
      {:ok, start_time_str} ->
        with {:ok, start_time, _} <- DateTime.from_iso8601(start_time_str) do
          start_time
        end

      {:error, _} ->
        default_time = DateTime.utc_now()
        change_event_start_time(default_time)
        default_time
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

  def feature_flag_keys do
    [
      "login_enabled",
      "schedule_enabled",
      "challenges_enabled",
      "speakers_enabled",
      "team_enabled",
      "survival_guide_enabled",
      "faqs_enabled",
      "general_regulation_enabled",
      "team_enabled"
    ]
  end

  def get_active_feature_flags! do
    feature_flag_keys()
    |> Constants.get_many!()
    |> Enum.filter(fn {_k, v} -> v == "true" end)
    |> Enum.map(fn {k, _v} -> k end)
  end

  def get_feature_flag!(flag) do
    with {:ok, value} <- Constants.get(flag), do: value == "true"
  end

  def get_feature_flags do
    feature_flag_keys()
    |> Enum.map(fn k -> with {:ok, v} <- Constants.get(k), do: {k, v} end)
    |> Enum.into(%{})
  end

  def change_feature_flags(flags) do
    flags
    |> Enum.each(fn {k, v} -> Constants.set(k, bool_to_string(v)) end)
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
      {:error, "key not found"} ->
        # If the date is not set, set it to today's date by default
        today = Timex.today()
        change_event_start_date(today)
        today

      {:ok, date} ->
        ensure_date(date)
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
      {:error, "key not found"} ->
        # If the date is not set, set it to today's date by default
        today = Timex.today()
        change_event_end_date(today)
        today

      {:ok, date} ->
        ensure_date(date)
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

  @doc """
  Gets a single FAQ.

  Raises `Ecto.NoResultsError` if the FAQ does not exist.

  ## Examples

      iex> get_faq!(123)
      %Faq{}

      iex> get_faq!(456)
      ** (Ecto.NoResultsError)

  """
  def get_faq!(id), do: Repo.get!(Faq, id)

  @doc """
  Returns the list of FAQs.

  ## Examples

      iex> list_faqs()
      [%Faq{}, %Faq{}]
  """
  def list_faqs do
    Repo.all(Faq)
  end

  @doc """
  Creates a new FAQ.

  ## Examples

      iex> create_faq(%{question: "Is SEI free?", answer: "Yes! SEI is completly free."})
      {:ok, %Faq{}}
  """
  def create_faq(attrs \\ %{}) do
    %Faq{}
    |> Faq.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a FAQ.

  ## Examples

      iex> update_faq(faq, %{question: "Is SEI free?", answer: "Yes! SEI is completly free."})
      {:ok, %Faq{}}
  """
  def update_faq(%Faq{} = faq, attrs) do
    faq
    |> Faq.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking FAQ changes.

  ## Examples

      iex> change_faq(faq)
      %Ecto.Changeset{data: %Faq{}}

  """
  def change_faq(%Faq{} = faq, attrs \\ %{}) do
    Faq.changeset(faq, attrs)
  end
end
