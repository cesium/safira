defmodule Mix.Tasks.Remove.Badge.Conflicts do
  use Mix.Task

  alias Safira.Accounts
  alias Safira.Contest

  def run(args) do
    cond do
      !Enum.empty?(args) ->
        Mix.shell().info("Needs no arguments.")

      true ->
        create()
    end
  end

  defp create() do
    Mix.Task.run("app.start")

    b1 =
      Contest.get_badge_description(
        "Assistir à Talk 2 Décadas de Progresso da IA (2000-19): os Novos Desafios"
      )

    b2 =
      Contest.get_badge_description(
        "Assistir à Talk Gimme a job... I mean: How to get a tech internship?"
      )

    b3 = Contest.get_badge_description("Assistir à Talk Machine Learning Lifecycle in the Cloud")

    b4 =
      Contest.get_badge_description("Assistir à Talk That first game I thought would be a hit!")

    b5 = Contest.get_badge_description("Assistir à Talk Let’s be Autonomous")
    b6 = Contest.get_badge_description("Assistir à Talk magIA @PRIMAVERA")
    b7 = Contest.get_badge_description("Assistir à Talk IOT at Ubiwhere")
    b8 = Contest.get_badge_description("Assistir à Talk Learning to Fly")
    b9 = Contest.get_badge_description("Assistir à Tertúlia Privacidade de Dados")
    b10 = Contest.get_badge_description("Assistir à Talk Remote work with Zapier")

    b11 =
      Contest.get_badge_description(
        "Assistir à Talk Design aberto e desenvolvimento iterativo na GitLab"
      )

    b12 = Contest.get_badge_description("Assistir à Talk Machine Learning in Production")
    b13 = Contest.get_badge_description("Assistir à Talk Continuous Stuff")

    b14 =
      Contest.get_badge_description(
        "Assistir à Talk How to reveal your impact? Deloitte explains"
      )

    b15 = Contest.get_badge_description("Assistir à Talk DevOps em Arquiteturas de Microserviços")
    b16 = Contest.get_badge_description("Assistir à Talk Cloud Delivery @KPMG")

    b17 =
      Contest.get_badge_description(
        "Assistir à Talk Why you should care about Application Security"
      )

    b18 = Contest.get_badge_description("Assistir à Talk Living inside Emacs")

    b19 =
      Contest.get_badge_description(
        "Assistir à Talk Como entregar e visualizar mais de 300GB de dados 3D em tempo real na web."
      )

    b20 = Contest.get_badge_description("Assistir à Tertúlia Empreendedorismo")

    b21 =
      Contest.get_badge_description("Assistir à Talk de Developing Software for Digital Trucks")

    b22 = Contest.get_badge_description("Assistir à Talk")
    b23 = Contest.get_badge_description("Assistir à Talk Do I need a hoodie to hack a bank?")
    b24 = Contest.get_badge_description("Assistir à Talk Let’s be a DevOps Engineer")
    b25 = Contest.get_badge_description("Assistir à Talk Olá!")
    b26 = Contest.get_badge_description("Assistir à Talk A transformação digital da mobilidade")
    b27 = Contest.get_badge_description("Assistir à Talk Computer Science in the Trading Floor")
    b28 = Contest.get_badge_description("Assistir à Talk Saving the bees with IoT and Elixir")
    b29 = Contest.get_badge_description("Assistir à Sessão de Abertura")
    b30 = Contest.get_badge_description("Participar no Workshop eID & ePassport: Hands on")

    b31 =
      Contest.get_badge_description(
        "Participar no Workshop Hands-on workshop: Angular for frontend developers"
      )

    b32 = Contest.get_badge_description("Participar no Workshop Rxjs on Quakes (Hands-On)")

    b33 =
      Contest.get_badge_description(
        "Participar no Workshop Know your Beer – Microsoft Power Platform"
      )

    b34 = Contest.get_badge_description("Participar no Workshop")

    b35 =
      Contest.get_badge_description(
        "Participar no Workshop Monitorização de infraestruturas e aplicações - Azure Monitor e Azure Application Insight"
      )

    b36 = Contest.get_badge_description("Participar no Workshop OutSystems 101 - BIT by Sonae MC")

    conflicts = %{
      b1.id => [b5, b31],
      b2.id => [b6, b31],
      b3.id => [b7, b32, b30],
      b4.id => [b8, b32, b30],
      b5.id => [b1, b31],
      b6.id => [b2, b31],
      b7.id => [b3, b30, b32],
      b8.id => [b4, b32, b30],
      b10.id => [b15, b19, b34],
      b11.id => [b17, b33, b35],
      b12.id => [b16, b33, b35],
      b13.id => [b14, b18, b34],
      b14.id => [b13, b18, b34],
      b15.id => [b10, b19, b34],
      b16.id => [b12, b33, b35],
      b17.id => [b11, b33, b35],
      b18.id => [b14, b13, b34],
      b19.id => [b15, b10, b34],
      b21.id => [b24, b36],
      b22.id => [b25, b28],
      b23.id => [b26, b27],
      b24.id => [b21, b36],
      b25.id => [b22, b28],
      b26.id => [b23, b27],
      b27.id => [b26, b23],
      b28.id => [b25, b22],
      b30.id => [b32, b3, b4, b7, b8],
      b31.id => [b1, b2, b5, b6],
      b32.id => [b30, b3, b4, b7, b8],
      b33.id => [b35, b11, b12, b16, b17],
      b34.id => [b10, b13, b14, b15, b18, b19],
      b35.id => [b33, b11, b12, b16, b17],
      b36.id => [b21, b24]
    }

    Accounts.list_active_attendees()
    |> Enum.each(fn a -> badge_attendees(conflicts, a) end)
  end

  defp badge_attendees(conflicts, attendee) do
    Enum.each(attendee.badges, fn b -> badge_conflits(conflicts, attendee.id, b) end)
  end

  defp badge_conflits(conflicts, attendee_id, badge) do    
    conflict = Map.get(conflicts, badge.id)
    if !is_nil(conflict) do
      Enum.each(conflict, fn c -> remove_conflits(c, attendee_id) end)
    end
  end

  defp remove_conflits(badge, attendee_id) do
    redeem = Contest.get_keys_redeem(attendee_id, badge.id)

    if !is_nil(redeem) do
      Contest.delete_redeem(redeem)
    end
  end
end
