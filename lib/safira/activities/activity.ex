defmodule Safira.Activities.Activity do
  @moduledoc """
  Activities scheduled for the event.
  """
  use Safira.Schema

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
  end

  @doc false
  def changeset_update_speakers(activity, speakers) do
    activity
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:speakers, speakers)
  end
end
