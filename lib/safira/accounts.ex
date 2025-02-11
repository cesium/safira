defmodule Safira.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Safira.Context

  alias Safira.Accounts.{Attendee, Course, Credential, Staff, User, UserNotifier, UserToken}
  alias Safira.Companies.Company
  alias Safira.Contest

  ## Database getters

  @doc """
  Lists all attendees.
  """
  def list_attendees do
    User
    |> where(type: :attendee)
    |> preload(:attendee)
    |> Repo.all()
  end

  def list_attendees(opts) when is_list(opts) do
    User
    |> apply_filters(opts)
    |> where(type: :attendee)
    |> preload(:attendee)
    |> Repo.all()
  end

  def list_attendees(params) do
    User
    |> where(type: :attendee)
    |> join(:left, [o], p in assoc(o, :attendee), as: :attendee)
    |> preload(:attendee)
    |> Flop.validate_and_run(params, for: User)
  end

  def list_attendees(%{} = params, opts) when is_list(opts) do
    User
    |> apply_filters(opts)
    |> where(type: :attendee)
    |> join(:left, [o], p in assoc(o, :attendee), as: :attendee)
    |> preload(:attendee)
    |> Flop.validate_and_run(params, for: User)
  end

  @doc """
  Lists all users with CV.
  """
  def list_users_with_cv do
    User
    |> where([user], not is_nil(user.cv))
    |> Repo.all()
  end

  @doc """
  Gets a single attendee by user id.
  """
  def get_user_attendee(user_id) do
    Attendee
    |> where(user_id: ^user_id)
    |> Repo.one()
  end

  @doc """
  Gets a single attendee.
  """
  def get_attendee!(id, opts \\ []) do
    Attendee
    |> where(id: ^id)
    |> apply_filters(opts)
    |> Repo.one!()
  end

  def update_attendee(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.changeset(attrs)
    |> Repo.update()
  end

  def change_attendee(%Attendee{} = attendee, attrs \\ %{}) do
    Attendee.changeset(attendee, attrs)
  end

  @doc """
  Checks if an attendee with a given id exists.
  """
  def attendee_exists?(id) do
    Attendee
    |> where(id: ^id)
    |> Repo.exists?()
  end

  @doc """
  Gets a single staff by user id.
  """
  def get_user_staff(user_id, opts \\ []) do
    Staff
    |> where(user_id: ^user_id)
    |> apply_filters(opts)
    |> Repo.one()
  end

  @doc """
  Gets a single company by user id.
  """
  def get_user_company(user_id, opts \\ []) do
    Company
    |> where(user_id: ^user_id)
    |> apply_filters(opts)
    |> Repo.one()
  end

  @doc """
  Gets a single staff.
  """
  def get_staff!(id) do
    Staff
    |> where(id: ^id)
    |> Repo.one!()
  end

  def load_user_associations(user) do
    Map.put(
      user,
      user.type,
      case user.type do
        :attendee -> get_user_attendee(user.id)
        :company -> get_user_company(user.id, preloads: [:tier])
        :staff -> get_user_staff(user.id, preloads: [:role])
      end
    )
  end

  @doc """
  Lists all staff users.
  """
  def list_staffs do
    User
    |> where(type: :staff)
    |> Repo.all()
  end

  def list_staffs(opts) when is_list(opts) do
    User
    |> apply_filters(opts)
    |> where(type: :staff)
    |> Repo.all()
  end

  def list_staffs(params) do
    User
    |> where(type: :staff)
    |> Flop.validate_and_run(params, for: User)
  end

  def list_staffs(%{} = params, opts) when is_list(opts) do
    User
    |> apply_filters(opts)
    |> where(type: :staff)
    |> Flop.validate_and_run(params, for: User)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Changes a staff
  """
  def change_staff(%Staff{} = staff, attrs \\ %{}) do
    Staff.changeset(staff, attrs)
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by handle.

  ## Examples

      iex> get_user_by_handle("lisasimpson")
      %User{}

      iex> get_user_by_handle("lisasimpson")
      nil

  """
  def get_user_by_handle!(handle) when is_binary(handle) do
    User
    |> preload([:attendee])
    |> Repo.get_by!(handle: handle)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers an attendee user.

  ## Examples

      iex> register_attendee_user(%{field: value})
      {:ok, %{user: %User{}, attendee: %Attendee{}}}

      iex> register_attendee_user(%{field: bad_value})
      {:error, :struct, %Ecto.Changeset{}, %{}}

  """
  def register_attendee_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user,
      User.registration_changeset(%User{}, Map.delete(attrs, :attendee),
        hash_password: true,
        validate_email: true
      )
    )
    |> Ecto.Multi.insert(
      :attendee,
      fn %{user: user} ->
        Attendee.changeset(%Attendee{}, %{user_id: user.id})
      end
    )
    |> Repo.transaction()
  end

  @doc """
  Registers a staff user.

  ## Examples

      iex> register_staff_user(%{field: value})
      {:ok, %User{}}

      iex> register_staff_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_staff_user(attrs) do
    attrs = attrs |> Map.put("type", :staff)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user,
      User.registration_changeset(
        %User{},
        Map.delete(attrs, "staff"),
        hash_password: true,
        validate_email: true
      )
    )
    |> Ecto.Multi.insert(
      :staff,
      fn %{user: user} ->
        staff_attrs =
          attrs
          |> Map.get("staff")
          |> Map.put("user_id", user.id)

        Staff.changeset(%Staff{}, staff_attrs)
      end
    )
    |> Ecto.Multi.update(
      :new_user,
      fn %{user: user} -> User.confirm_changeset(user) end
    )
    |> Repo.transaction()
  end

  @doc """
  Creates an attendee.
  """
  def create_attendee(attrs \\ %{}) do
    %Attendee{}
    |> Attendee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a staff.
  """
  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user profile (name, handle, password and email).
  Doesn't validate the uniqueness of the email.

  ## Examples

      iex> change_user_profile(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_profile(user, attrs \\ %{}) do
    user
    |> User.profile_changeset(attrs, validate_email: false)
    |> User.picture_changeset(attrs)
  end

  @doc """
  Updates the user profile (name, handle, password).

  If everything succeed, emulates that the email was change without
  actually changing it in the database.
  """
  def update_user_profile(%User{} = user, current_password, attrs) do
    password_changed? =
      attrs["password"] != nil && String.trim(attrs["password"]) != ""

    changeset =
      user
      |> User.profile_changeset(attrs, validate_email: true)
      |> maybe_validate_current_password(password_changed?, current_password)

    # Just simulate a complete update, to check if everything is valid
    applied_user = Ecto.Changeset.apply_action(changeset, :update)

    case applied_user do
      {:ok, _} ->
        # Removing the email from the changeset, since the mail just will be updated over mail confirmation
        changeset_without_mail_update = Ecto.Changeset.change(changeset, email: user.email)

        tokens_to_delete = if password_changed?, do: :all, else: ["false"]

        Ecto.Multi.new()
        |> Ecto.Multi.update(:user, changeset_without_mail_update)
        # The tokens will just be deleted if the password was changed
        |> Ecto.Multi.delete_all(
          :tokens,
          UserToken.by_user_and_contexts_query(user, tokens_to_delete)
        )
        |> Repo.transaction()
        |> case do
          # Return the user with ALL the changes
          {:ok, _} -> applied_user
          {:error, :user, changeset, _} -> {:error, changeset}
        end

      otherwise ->
        otherwise
    end
  end

  defp maybe_validate_current_password(changeset, password_changed?, current_password) do
    if password_changed? do
      User.validate_current_password(changeset, current_password)
    else
      changeset
    end
  end

  def update_user_picture(%User{} = user, attrs) do
    user
    |> User.picture_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's CV.

  ## Examples

      iex> update_user_cv(user, %{cv: cv})
      {:ok, %User{}}

      iex> update_user_cv(user, %{cv: bad_cv})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_cv(%User{} = user, attrs) do
    user
    |> User.cv_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, user} ->
        if user.type == :attendee do
          Contest.enqueue_badge_trigger_execution_job(user.attendee, :upload_cv_event)
        end

        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
    |> User.password_confirmation_changeset(attrs)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      case UserNotifier.deliver_welcome_email(user) do
        {:ok, _} ->
          {:ok, user}

        {:error, _message} ->
          {:ok, user}
      end
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Qr code does not exist.

  ## Examples

      iex> get_credential!(123)
      %Credential{}

      iex> get_credential!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id, preloads \\ []), do: Repo.get!(Credential, id) |> Repo.preload(preloads)

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Links a credential to an attendee.

  ## Examples

      iex> link_credential(credential_id, attendee_id)
      {:ok, %Credential{}}

      iex> link_credential(credential_id, attendee_id)
      {:error, %Ecto.Changeset{}}

  """
  def link_credential(credential_id, attendee_id) do
    credential = get_credential!(credential_id)
    attendee = get_attendee!(attendee_id)

    credential
    |> Credential.changeset(%{attendee_id: attendee.id})
    |> Repo.update()
    |> case do
      {:ok, _} = result ->
        # If the credential is successfully linked to the attendee, trigger the badge event
        Contest.enqueue_badge_trigger_execution_job(attendee, :link_credential_event)
        result

      {:error, _} = result ->
        result
    end
  end

  @doc """
  Deletes a credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{data: %Credential{}}

  """
  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end

  @doc """
  Checks if a credential exists.

  ## Examples

      iex> credential_exists?(123)
      true

      iex> credential_exists?(456)
      false

  """
  def credential_exists?(id) do
    Credential
    |> where([c], c.id == ^id)
    |> Repo.exists?()
  end

  @doc """
  Checks if a credential is linked to an attendee.

  ## Examples

      iex> credential_linked?(credential_id)
      true

      iex> credential_linked?(credential_id)
      false

  """
  def credential_linked?(credential_id) do
    credential = get_credential!(credential_id)

    credential.attendee_id != nil
  end

  @doc """
  Gets a single credential associated to the given attendee.

  Raises `Ecto.NoResultsError` if the credential does not exist.

  ## Examples

      iex> get_credential_of_attendee!(%Attendee{})
      %Credential{}

      iex> get_credential_of_attendee!(%Attendee{})
      ** (Ecto.NoResultsError)

  """
  def get_credential_of_attendee!(%Attendee{} = attendee) do
    Credential
    |> where([c], c.attendee_id == ^attendee.id)
    |> Repo.one!()
  end

  @doc """
  Checks if an attendee has a credential.

  ## Examples

      iex> attendee_has_credential?(123)
      true

      iex> attendee_has_credential?(456)
      false

  """
  def attendee_has_credential?(attendee_id) do
    Credential
    |> where([c], c.attendee_id == ^attendee_id)
    |> Repo.exists?()
  end

  @doc """
  Gets a single attendee associated to the given credential.

  ## Examples

      iex> get_attendee_from_credential(123)
      %Attendee{}

      iex> get_attendee_from_credential(456)
      nil
  """
  def get_attendee_from_credential(credential_id, preloads \\ []) do
    Credential
    |> where([c], c.id == ^credential_id)
    |> join(:inner, [c], a in assoc(c, :attendee))
    |> select([c, a], a)
    |> Repo.one()
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id, preloads \\ []), do: Repo.get!(Course, id) |> Repo.preload(preloads)

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  @doc """
  Gets a single credential associated to the given attendee.

  ## Examples

      iex> get_credential_of_attendee(%Attendee{})
      %Credential{}

      iex> get_credential_of_attendee!(%Attendee{})
      nil

  """
  def get_credential_of_attendee(%Attendee{} = attendee) do
    Credential
    |> where([c], c.attendee_id == ^attendee.id)
    |> Repo.one()
  end

  def generate_credentials(count) do
    for _ <- 1..count do
      {:ok, credential} = create_credential(%{})

      phx_host =
        if System.get_env("PHX_HOST") != nil do
          "https://" <> System.get_env("PHX_HOST")
        else
          ""
        end

      png =
        "#{phx_host}/attendee/#{credential.id}"
        |> QRCodeEx.encode()
        |> QRCodeEx.png()

      {credential.id, [png]}
    end
  end
end
