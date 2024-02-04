defmodule Safira.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Company
  alias Safira.Accounts.Course
  alias Safira.Accounts.Staff
  alias Safira.Accounts.User

  alias Safira.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_preload!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:attendee)
    |> Repo.preload(:company)
    |> Repo.preload(:staff)
  end

  def get_user_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_preload_email!(email) do
    Repo.get_by!(User, email: email)
    |> Repo.preload(:attendee)
    |> Repo.preload(:company)
    |> Repo.preload(:staff)
  end

  def get_user_preload_email(email) do
    Repo.get_by(User, email: email)
    |> Repo.preload(:attendee)
    |> Repo.preload(:company)
    |> Repo.preload(:staff)
  end

  def get_user_token(token) do
    Repo.get_by(User, reset_password_token: token)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_attendees do
    Repo.all(Attendee)
  end

  def list_active_attendees do
    Repo.all(from a in Attendee, where: not is_nil(a.user_id))
    |> Repo.preload(:badges)
    |> Repo.preload(:prizes)
    |> Enum.map(fn x ->
      Map.put(x, :badge_count, length(Enum.filter(x.badges, fn x -> x.type != 0 end)))
    end)
  end

  def get_attendee!(id) do
    Repo.get!(Attendee, id)
    |> Repo.preload(:badges)
    |> Repo.preload(:user)
    |> Repo.preload(:prizes)
  end

  def get_attendee(id) do
    Repo.get(Attendee, id)
    |> Repo.preload(:badges)
    |> Repo.preload(:user)
    |> Repo.preload(:prizes)
    |> Repo.preload(:course)
  end

  def get_attendee_with_badge_count_by_id!(id) do
    case get_attendee(id) do
      nil ->
        nil

      %Attendee{} = attendee ->
        badges =
          attendee.badges
          |> Enum.filter(&(&1.type != 0))

        Map.put(attendee, :badge_count, length(badges))
    end
  end

  def get_attendee_with_badge_count_by_username(username) do
    case get_attendee_by_username!(username) do
      %Attendee{} = attendee ->
        badges =
          attendee.badges
          |> Enum.filter(&(&1.type != 0))

        Map.put(attendee, :badge_count, length(badges))

      _ ->
        nil
    end
  end

  def get_attendee_by_username!(username) do
    Repo.get_by!(Attendee, nickname: username)
    |> Repo.preload(:badges)
    |> Repo.preload(:user)
    |> Repo.preload(:prizes)
  end

  def get_attendee_by_discord_association_code(discord_association_code) do
    case Ecto.UUID.cast(discord_association_code) do
      {:ok, casted_code} -> Repo.get_by(Attendee, discord_association_code: casted_code)
      _ -> nil
    end
  end

  def get_attendee_by_discord_id(discord_id) do
    Repo.get_by(Attendee, discord_id: discord_id)
  end

  def create_attendee(attrs \\ %{}) do
    %Attendee{}
    |> Attendee.changeset(attrs)
    |> Repo.insert()
  end

  def update_attendee(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.update_changeset(attrs)
    |> Repo.update()
  end

  def update_attendee_association(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.update_changeset_discord_association(attrs)
    |> Repo.update()
  end

  def update_attendee_sign_up(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.update_changeset_sign_up(attrs)
    |> Repo.update()
  end

  def delete_attendee(%Attendee{} = attendee) do
    Repo.delete(attendee)
  end

  def change_attendee(%Attendee{} = attendee) do
    Attendee.changeset(attendee, %{})
  end

  def list_staffs do
    Repo.all(Staff)
  end

  def get_staff!(id), do: Repo.get!(Staff, id)

  def get_staff_by_email(email) do
    Repo.all(
      from m in Staff,
        join: u in assoc(m, :user),
        where: u.email == ^email,
        preload: [user: u]
    )
  end

  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.changeset(attrs)
    |> Repo.insert()
  end

  def update_staff(%Staff{} = staff, attrs) do
    staff
    |> Staff.changeset(attrs)
    |> Repo.update()
  end

  def update_staff_cv(%Staff{} = staff, attrs) do
    staff
    |> Staff.update_cv_changeset(attrs)
    |> Repo.update()
  end

  def delete_staff(%Staff{} = staff) do
    Repo.delete(staff)
  end

  def change_staff(%Staff{} = staff) do
    Staff.changeset(staff, %{})
  end

  def list_companies do
    Repo.all(Company)
  end

  def get_company!(id), do: Repo.get!(Company, id)

  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  alias Safira.Contest.Redeem

  @doc """
  Returns the list of attendees for a company based on the company's sponsorship level.
  """
  def list_company_attendees(company_id) do
    company = get_company!(company_id)

    if company.sponsorship in ["Bronze", "Silver"] do
      badge_id =
        company_id
        |> get_company!()
        |> then(fn x -> x.badge_id end)

      Repo.all(
        from r in Redeem,
          where: r.badge_id == ^badge_id,
          join: a in assoc(r, :attendee),
          preload: [attendee: a]
      )
      |> Enum.map(fn x -> x.attendee end)
    else
      Repo.all(Attendee)
    end
  end

  def is_company(conn) do
    get_user(conn)
    |> Map.fetch!(:company)
    |> is_nil
    |> Kernel.not()
  end

  def is_staff(conn) do
    get_user(conn)
    |> Map.fetch!(:staff)
    |> is_nil
    |> Kernel.not()
  end

  def is_admin(conn) do
    staff =
      get_user(conn)
      |> Map.fetch(:staff)

    case staff do
      {:error} ->
        false

      {:ok, nil} ->
        false

      {:ok, man} ->
        man.is_admin
    end
  end

  def get_user(conn) do
    with %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
      |> Map.fetch!(:id)
      |> get_user_preload!()
    end
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Course
    |> order_by(:id)
    |> Repo.all()
  end
end
