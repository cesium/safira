defmodule SafiraWeb.ErrorHTMLTest do
  use SafiraWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(SafiraWeb.ErrorHTML, "404", "html", []) =~
             "You're in the wrong line of code, pal.\n"
  end

  test "renders 500.html" do
    assert render_to_string(SafiraWeb.ErrorHTML, "500", "html", []) == "Internal Server Error\n"
  end
end
