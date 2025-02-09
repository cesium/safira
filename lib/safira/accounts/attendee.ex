defmodule Safira.Accounts.Attendee do
  @moduledoc """
  An event attendee.
  """
  use Safira.Schema

  @required_fields ~w(user_id)a
  @optional_fields ~w(tokens entries course_id)a

  schema "attendees" do
    field :tokens, :integer, default: 0
    field :entries, :integer, default: 0

    belongs_to :course, Safira.Accounts.Course
    belongs_to :user, Safira.Accounts.User

    has_many :enrolments, Safira.Activities.Enrolment

    timestamps(type: :utc_datetime)
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:user)
    |> cast_assoc(:course)
    |> validate_required(@required_fields)
  end

  def update_tokens_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:tokens])
    |> validate_required([:tokens])
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
  end

  def update_entries_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:entries])
    |> validate_required([:entries])
    |> validate_number(:entries, greater_than_or_equal_to: 0)
  end
end
