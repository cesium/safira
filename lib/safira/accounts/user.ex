defmodule Safira.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee


  schema "users" do
    field :email, :string
    field :password_hash, :string

    has_one :attendee, Attendee, on_delete: :delete_all

    # Virtual fields:
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8) 
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> genput_password_hash
  end

  defp genput_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
