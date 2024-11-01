defmodule Safira.Activities.Activity do
  @moduledoc """
  Activities scheduled for the event.
  """
  use Safira.Schema

  @required_fields ~w(title date time_start time_end)a
  @optional_fields ~w(description category_id location has_enrolments)a

  @derive {
    Flop.Schema,
    filterable: [:title], sortable: [:title, :date], default_limit: 11
  }

  schema "activities" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :date, :date
    field :time_start, :time
    field :time_end, :time
    field :has_enrolments, :boolean, default: false

    belongs_to :category, Safira.Activities.ActivityCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
