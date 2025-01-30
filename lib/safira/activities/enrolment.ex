defmodule Safira.Activities.Enrolment do
  @moduledoc """
  Enrollments for activities.
  """

  use Safira.Schema

  alias Safira.Accounts.Attendee
  alias Safira.Activities.Activity

  @required_fields ~w(attendee_id activity_id)a

  schema "enrolments" do
    belongs_to :attendee, Attendee
    belongs_to :activity, Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(enrolment, attrs) do
    enrolment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:activity_id, :attendee_id])
  end
end
