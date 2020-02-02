defmodule Safira.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Manager
  alias Safira.Accounts.Company


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :ban, :boolean, default: false

    has_one :attendee, Attendee, on_delete: :delete_all
    has_one :manager, Manager, on_delete: :delete_all
    has_one :company, Company, on_delete: :delete_all

    field :reset_password_token, :string
    field :reset_token_sent_at, :utc_datetime

    # Virtual fields:
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :type, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> downcase_email
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/\A[^@\s]+@[^@\s]+\z/)
    |> validate_length(:password, min: 8) 
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> genput_password_hash
  end

  def password_token_changeset(user, attrs) do
    user
    |> cast(attrs, [:reset_password_token, :reset_token_sent_at])
    #|> validate_required([:reset_password_token, :reset_token_sent_at])
  end

  def update_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
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

  defp downcase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end
end
