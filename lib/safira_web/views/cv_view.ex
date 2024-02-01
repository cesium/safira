defmodule SafiraWeb.CVView do
  use SafiraWeb, :view

  alias Safira.CV

  def render("staff_cv.json", %{staff: staff}) do
    %{
      id: staff.id,
      cv: CV.url({staff.cv, staff}, :original)
    }
  end
end
