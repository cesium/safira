defmodule SafiraWeb.ErrorHTMLTest do
  use SafiraWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    html = render_to_string(SafiraWeb.ErrorHTML, "404", "html", [])
    assert html =~ "404"
    assert html =~ "in the wrong line of code, pal."
  end

  test "renders 500.html" do
    html = render_to_string(SafiraWeb.ErrorHTML, "500", "html", [])
    assert html =~ "500"
    assert html =~ "Sorry! Our monkeys gave up on working."
  end
end
