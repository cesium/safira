defmodule SafiraWeb.Config do
  @moduledoc """
  Web configuration for the app.
  """

  alias Safira.Event

  def landing_pages do
    enabled_flags = Event.get_active_feature_flags!()

    [
      %{
        title: "Schedule",
        url: "/schedule",
        feature_flag: "schedule_enabled"
      },
      %{
        title: "Team",
        url: "/team",
        feature_flag: "team_enabled"
      },
      %{
        title: "Challenges",
        url: "/challenges",
        feature_flag: "challenges_enabled"
      },
      %{
        title: "Speakers",
        url: "/speakers",
        feature_flag: "speakers_enabled"
      },
      %{
        title: "FAQs",
        url: "/faqs",
        feature_flag: "faqs_enabled"
      },
      %{
        title: "Call for Staff",
        url: "https://forms.gle/XWHoNu4LjC8BogF68",
        feature_flag: "call_for_staff_enabled"
      }
    ]
    |> Enum.filter(fn x -> Enum.member?(enabled_flags, x.feature_flag) end)
  end

  def app_pages do
    if Event.event_started?() do
      [
        %{
          key: :badges,
          title: "Badgedex",
          icon: "hero-check-badge",
          url: "/app/badges"
        },
        %{
          key: :wheel,
          title: "Wheel",
          icon: "hero-circle-stack",
          url: "/app/wheel"
        },
        %{
          key: :coin_flip,
          title: "Coin Flip",
          icon: "hero-circle-stack",
          url: "/app/coin_flip"
        },
        %{
          key: :slots,
          title: "Slots",
          icon: "hero-circle-stack",
          url: "/app/slots"
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
          icon: "hero-qr-code",
          url: "/app/credential"
        }
      ]
    else
      []
    end
  end

  def sponsor_pages do
    [
      %{
        key: :visitors,
        title: "Visitors",
        icon: "hero-user",
        url: "/sponsor"
      }
    ]
  end

  def backoffice_pages(user) do
    permissions = user.staff.role.permissions

    [
      %{
        key: :attendees,
        title: "Attendees",
        icon: "hero-user-group",
        url: "/dashboard/attendees",
        scope: %{"attendees" => ["show"]}
      },
      %{
        key: :staffs,
        title: "Personnel",
        icon: "hero-hand-raised",
        url: "/dashboard/staffs",
        scope: %{"staffs" => ["show"]}
      },
      %{
        key: :companies,
        title: "Companies",
        icon: "hero-building-office",
        url: "/dashboard/companies",
        scope: %{"companies" => ["edit"]}
      },
      %{
        key: :store,
        title: "Store",
        icon: "hero-shopping-cart",
        url: "/dashboard/store/products",
        scope: %{"products" => ["show"]}
      },
      %{
        key: :badges,
        title: "Badges",
        icon: "hero-check-badge",
        url: "/dashboard/badges",
        scope: %{"badges" => ["show"]}
      },
      %{
        key: :prizes,
        title: "Prizes",
        icon: "hero-gift",
        url: "/dashboard/minigames/prizes",
        scope: %{"minigames" => ["show"]}
      },
      %{
        key: :challenges,
        title: "Challenges",
        icon: "hero-beaker",
        url: "/dashboard/minigames/challenges",
        scope: %{"challenges" => ["show"]}
      },
      %{
        key: :minigames,
        title: "Minigames",
        icon: "hero-sparkles",
        url: "/dashboard/minigames",
        scope: %{"minigames" => ["show"]}
      },
      %{
        key: :spotlights,
        title: "Spotlights",
        icon: "hero-fire",
        url: "/dashboard/spotlights",
        scope: %{"spotlights" => ["edit"]}
      },
      %{
        key: :schedule,
        title: "Schedule",
        icon: "hero-calendar-days",
        url: "/dashboard/schedule/activities",
        scope: %{"schedule" => ["edit"]}
      },
      %{
        key: :statistics,
        title: "Statistics",
        icon: "hero-chart-bar",
        url: "/dashboard/statistics",
        scope: %{"statistics" => ["show"]}
      },
      %{
        key: :mailer,
        title: "Mailer",
        icon: "hero-envelope",
        url: "/dashboard/mailer",
        scope: %{"mailer" => ["send"]}
      },
      %{
        key: :scanner,
        title: "Scanner",
        icon: "hero-qr-code",
        url: "/dashboard/scanner",
        scope: %{"scanner" => ["show"]}
      },
      %{
        key: :event,
        title: "Event",
        icon: "hero-cog-8-tooth",
        url: "/dashboard/event",
        scope: %{"event" => ["edit"]}
      }
    ]
    |> Enum.filter(fn page -> has_permission?(permissions, page.scope) end)
  end

  defp has_permission?(user_permissions, required_scope) do
    Enum.all?(required_scope, fn {resource, actions} ->
      user_actions = Map.get(user_permissions, resource, [])
      Enum.all?(actions, &(&1 in user_actions))
    end)
  end
end
