defmodule SafiraWeb.Config do
  @moduledoc """
  Web configuration for the app.
  """

  def app_pages do
    [
      %{
        key: :badgedex,
        title: "Badgedex",
        icon: "hero-check-badge",
        url: "/app/badgedex"
      },
      %{
        key: :wheel,
        title: "Wheel",
        icon: "hero-circle-stack",
        url: "/app/wheel"
      },
      %{
        key: :leaderboard,
        title: "Leaderboard",
        icon: "hero-trophy",
        url: "/app/leaderboard"
      },
      %{
        key: :store,
        title: "Store",
        icon: "hero-shopping-bag",
        url: "/app/store"
      },
      %{
        key: :vault,
        title: "Vault",
        icon: "hero-archive-box",
        url: "/app/vault"
      },
      %{
        key: :credential,
        title: "Credential",
        icon: "hero-ticket",
        url: "/app/credential"
      }
    ]
  end

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
        key: :prizes,
        title: "Prizes",
        icon: "hero-gift",
        url: "/dashboard/minigames/prizes"
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
        key: :scanner,
        title: "Scanner",
        icon: "hero-qr-code",
        url: "/dashboard/scanner"
      }
    ]
  end
end
