defmodule SafiraWeb.Helpers do
  def text_to_html_paragraphs(text) do
    text
    |> String.split(~r/\n/)
    |> Enum.map(&"<p>#{&1}</p>")
    |> Enum.join()
    |> Phoenix.HTML.raw()
  end
end
