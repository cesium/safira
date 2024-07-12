defmodule SafiraWeb.Config do
  @moduledoc """
  Web configuration for the app.
  """

  def backoffice_pages do
    [
      %{
        key: :attendees,
        title: "Attendees",
        icon: "hero-user-group",
        url: "/dashboard/attendees"
      },
      %{
        key: :staffs,
        title: "Personnel",
        icon: "hero-hand-raised",
        url: "/dashboard/staffs"
      },
      %{
        key: :store,
        title: "Store",
        icon: "hero-shopping-cart",
        url: "/dashboard/store/products"
      },
      %{
        key: :badges,
        title: "Badges",
        icon: "hero-check-badge",
        url: "/dashboard/badges"
      },
      %{
        key: :minigames,
        title: "Minigames",
        icon: "hero-sparkles",
        url: "/dashboard/minigames"
      },
      %{
        key: :spotlights,
        title: "Spotlights",
        icon: "hero-fire",
        url: "/dashboard/spotlights"
      },
      %{
        key: :statistics,
        title: "Statistics",
        icon: "hero-chart-bar",
        url: "/dashboard/statistics"
      },
      %{
        key: :mailer,
        title: "Mailer",
        icon: "hero-envelope",
        url: "/dashboard/mailer"
      },
      %{
        key: :terminal,
        title: "Terminal",
        icon: "hero-command-line",
        url: "/dashboard/terminal"
      },
      %{
        key: :scanner,
        title: "Scanner",
        icon: "hero-qr-code",
        url: "/dashboard/scanner"
      }
    ]
  end
end
