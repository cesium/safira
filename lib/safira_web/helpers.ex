defmodule SafiraWeb.Helpers do
  @moduledoc """
  Helper functions for web views.
  """
  alias Timex.Format.DateTime.Formatters.Relative

  require Timex.Translator

  def text_to_html_paragraphs(text) do
    text
    |> String.split(~r/\n/)
    |> Enum.map_join(&"<p>#{&1}</p>")
    |> Phoenix.HTML.raw()
  end

  def safely_extract_id_from_url(url) do
    app_host = System.get_env("PHX_HOST")

    case URI.parse(url) do
      %URI{host: host, path: path} ->
        if host == app_host or Mix.env() == :dev do
          case extract_id_from_url_path(path) do
            :error -> {:error, "not a valid id"}
            result -> result
          end
        else
          {:error, "invalid host"}
        end
    end
  end

  defp extract_id_from_url_path(path) do
    path
    |> String.split("/")
    |> List.last()
    |> Ecto.UUID.cast()
  end

  @doc """
  Returns a relative datetime string for the given datetime.

  ## Examples

      iex> relative_datetime(Timex.today() |> Timex.shift(years: -3))
      "3 years ago"

      iex> relative_datetime(Timex.today() |> Timex.shift(years: 3))
      "in 3 years"

      iex> relative_datetime(Timex.today() |> Timex.shift(months: -8))
      "8 months ago"

      iex> relative_datetime(Timex.today() |> Timex.shift(months: 8))
      "in 8 months"

      iex> relative_datetime(Timex.today() |> Timex.shift(days: -1))
      "yesterday"

  """
  def relative_datetime(nil), do: ""

  def relative_datetime(""), do: ""

  def relative_datetime(datetime) do
    Relative.lformat!(datetime, "{relative}", Gettext.get_locale())
  end

  @doc """
  Returns a relative date string for the given date.

  ## Examples

      iex> display_date(~D[2020-01-01])
      "01-01-2020"

      iex> display_date(~D[2023-01-01])
      "01-01-2023"

  """
  def display_date(nil), do: ""

  def display_date(""), do: ""

  def display_date(date) when is_binary(date) do
    date
    |> Timex.parse!("%FT%H:%M", :strftime)
    |> Timex.format!("{0D}-{0M}-{YYYY}")
  end

  def display_date(date) do
    Timex.format!(date, "{0D}-{0M}-{YYYY}")
  end

  @doc """
  Returns a relative time string for the given time.

  ## Examples

      iex> display_time(~T[00:00:00])
      "00:00"

      iex> display_time(~T[23:59:59])
      "23:59"
  """
  def display_time(nil), do: ""

  def display_time(""), do: ""

  def display_time(date) when is_binary(date) do
    date
    |> Timex.parse!("%FT%H:%M", :strftime)
    |> Timex.format!("{0D}-{0M}-{YYYY}")
  end

  def display_time(date) do
    date
    |> Timex.format!("{h24}:{m}")
  end

  @doc """
  Returns a pretty date string for the given date.

  ## Examples

      iex> pretty_display_date(~D[2020-01-01])
      "Wed, 1 Jan"

      iex> pretty_display_date(~D[2023-01-01])
      "Sun, 1 Jan"

      iex> pretty_display_date(~D[2023-01-01], "pt")
      "Dom, 1 de Jan"
  """
  def pretty_display_date(date, locale \\ "en")

  def pretty_display_date(date, "en" = locale) do
    Timex.Translator.with_locale locale do
      Timex.format!(date, "{WDshort}, {D} {Mshort}")
    end
  end

  def pretty_display_date(date, "pt" = locale) do
    Timex.Translator.with_locale locale do
      Timex.format!(date, "{WDshort}, {D} de {Mshort}")
    end
  end

  defp build_url do
    if Mix.env() == :dev do
      "http://localhost:4000"
    else
      "https://#{Application.fetch_env!(:safira, SafiraWeb.Endpoint)[:url][:host]}"
    end
  end

  def draw_qr_code(qr_code) do
    internal_route = "/qr_codes/#{qr_code.id}"
    url = build_url() <> internal_route

    url
    |> QRCodeEx.encode()
    |> QRCodeEx.svg(background_color: "#FFFFFF", color: "#04041C", width: 200)
  end
end