defmodule Safira.Accounts.User do
  @moduledoc """
  Application user.
  """
  use Safira.Schema

  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Staff

  @required_fields ~w(name email handle password type)a
  @optional_fields ~w(confirmed_at allows_marketing)a

  @derive {
    Flop.Schema,
    filterable: [:name],
    sortable: [:name, :tokens, :entries],
    default_limit: 8,
    join_fields: [
      tokens: [
        binding: :attendee,
        field: :tokens,
        path: [:attendee, :tokens],
        ecto_type: :integer
      ],
      entries: [
        binding: :attendee,
        field: :entries,
        path: [:attendee, :entries],
        ecto_type: :integer
      ]
    ]
  }

  schema "users" do
    field :name, :string
    field :email, :string
    field :handle, :string
    field :picture, Safira.Uploaders.UserPicture.Type
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime
    field :type, Ecto.Enum, values: [:attendee, :staff], default: :attendee
    field :allows_marketing, :boolean, default: false

    has_one :attendee, Attendee, on_delete: :delete_all
    has_one :staff, Staff, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields |> Enum.reject(&(&1 in [:email, :password, :handle])))
    |> validate_email(opts)
    |> validate_handle()
    |> validate_password(opts)
    |> cast_assoc(:attendee, with: &Attendee.changeset/2)
  end

  @doc """
  A user changeset for changing the profile (name, handle, password and email).
  """
  def profile_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :handle, :email])
    |> validate_handle()
    |> email_changeset(attrs, opts |> Keyword.put(:check_email_changed, false))
    |> if_changed_password_changeset(attrs, opts)
  end

  defp if_changed_password_changeset(changeset, attrs, opts) do
    password = Map.get(attrs, "password")
    password_exists? = password != nil && String.trim(password) != ""

    case password_exists? do
      true -> password_changeset(changeset, attrs, opts)
      false -> changeset
    end
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp validate_handle(changeset) do
    changeset
    |> validate_required([:handle])
    |> validate_length(:handle, min: 3, max: 20)
    |> validate_format(:handle, ~r/^[a-z0-9_]+$/,
      message: "can only contain lowercase letters, numbers, and underscores"
    )
    |> unsafe_validate_unique(:handle, Safira.Repo)
    |> unique_constraint(:handle)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Safira.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  ## Options

   * `:check_email_changed` - If true, it requires the email to change, otherwise an error is added.
      Defaults to `true`.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> maybe_validate_email_changed(opts)
  end

  defp maybe_validate_email_changed(%{changes: %{email: _}} = changeset, _opts), do: changeset

  defp maybe_validate_email_changed(changeset, opts) do
    check_email_changed? = Keyword.get(opts, :check_email_changed, true)

    case check_email_changed? do
      true -> changeset |> add_error(:email, "did not change")
      false -> changeset
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  def password_confirmation_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Safira.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "password not correct")
    end
  end

  @doc false
  def picture_changeset(user, attrs) do
    user
    |> cast_attachments(attrs, [:picture])
  end
end
