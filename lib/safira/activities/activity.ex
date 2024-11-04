defmodule Safira.Activities.Activity do
  @moduledoc """
  Activities scheduled for the event.
  """
  use Safira.Schema

  alias Safira.Event

  @required_fields ~w(title date time_start time_end)a
  @optional_fields ~w(description category_id location has_enrolments max_enrolments)a

  @derive {
    Flop.Schema,
    filterable: [:title],
    sortable: [:timestamp],
    default_limit: 11,
    adapter_opts: [
      compound_fields: [
        timestamp: [:date, :time_start]
      ]
    ],
    default_order: %{
      order_by: [:timestamp],
      order_directions: [:asc]
    }
  }

  schema "activities" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :date, :date
    field :time_start, :time
    field :time_end, :time
    field :has_enrolments, :boolean, default: false
    field :max_enrolments, :integer, default: 0

    belongs_to :category, Safira.Activities.ActivityCategory

    many_to_many :speakers, Safira.Activities.Speaker,
      join_through: "activities_speakers",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_activity_date()
    |> validate_activity_times()
  end

  @doc false
  def changeset_update_speakers(activity, speakers) do
    activity
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:speakers, speakers)
  end

  def validate_activity_date(activity) do
    event_start = Event.get_event_start_date()
    event_end = Event.get_event_end_date()
    date = get_field(activity, :date)

    # Validate if the activity's date is within the event's start and end date
    if date != nil do
      if Date.compare(date, event_start) in [:lt] do
        activity
        |> Ecto.Changeset.add_error(
          :date,
          "must be after or in the event's start date (#{Date.to_string(event_start)})"
        )
      else
        if Date.compare(date, event_end) in [:gt] do
          activity
          |> Ecto.Changeset.add_error(
            :date,
            "must be before or in the event's end date (#{Date.to_string(event_end)})"
          )
        else
          activity
        end
      end
    else
      activity
    end
  end

  def validate_activity_times(activity) do
    time_start = get_field(activity, :time_start)
    time_end = get_field(activity, :time_end)

    # Validate if the activity's time_end is after time_start
    if time_start != nil and time_end != nil do
      if Time.compare(time_end, time_start) in [:lt] do
        activity
        |> Ecto.Changeset.add_error(
          :time_end,
          "must be after the activity's start time (#{Time.to_string(time_start)})"
        )
      else
        activity
      end
    else
      activity
    end
  end
end
