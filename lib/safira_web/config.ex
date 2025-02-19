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

  def app_pages(attendee_eligible?) do
    if Event.event_started?() do
      [
        %{
          key: :home,
          title: "Home",
          image: "/images/icons/home.svg",
          url: "/app/",
          enabled: true
        },
        %{
          key: :badges,
          title: "Badgedex",
          image: "/images/icons/badgedex.svg",
          url: "/app/badges",
          enabled: true
        },
        %{
          key: :wheel,
          title: "Wheel",
          image: "/images/icons/wheel.svg",
          url: "/app/wheel",
          enabled: attendee_eligible?
        },
        %{
          key: :coin_flip,
          title: "Coin Flip",
          image: "/images/icons/coin-flip.svg",
          url: "/app/coin_flip",
          enabled: attendee_eligible?
        },
        %{
          key: :slots,
          title: "Slots",
          image: "/images/icons/slots.svg",
          url: "/app/slots",
          enabled: true
        },
        %{
          key: :leaderboard,
          title: "Leaderboard",
          image: "/images/icons/leaderboard.svg",
          url: "/app/leaderboard",
          enabled: true
        },
        %{
          key: :store,
          title: "Store",
          image: "/images/icons/store.svg",
          url: "/app/store",
          enabled: true
        },
        %{
          key: :vault,
          title: "Vault",
          image: "/images/icons/vault.svg",
          url: "/app/vault",
          enabled: true
        },
        %{
          key: :credential,
          title: "Credential",
          image: "/images/icons/scanner.svg",
          url: "/app/credential",
          enabled: true
        }
      ]
      |> Enum.filter(& &1.enabled)
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
      },
      %{
        key: :scanner,
        title: "Scanner",
        icon: "hero-qr-code",
        url: "/sponsor/scanner"
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
