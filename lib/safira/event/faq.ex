defmodule Safira.Event.Faq do
  @moduledoc """
  A frequently asked question.
  """
  use Safira.Schema

  @required_fields ~w(answer question)a

  schema "faqs" do
    field :answer, :string
    field :question, :string

    timestamps()
  end

  @doc false
  def changeset(faq, attrs) do
    faq
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
