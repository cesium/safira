defmodule Safira.InteractionTest do
  use Safira.DataCase

  alias Safira.Interaction

  describe "list_bonuses/0" do
    test "no bonuses" do
      assert Interaction.list_bonuses() == []
    end

    test "multiple bonuses" do
      bonuses = insert_list(3, :bonus)

      assert Interaction.list_bonuses() == bonuses
    end
  end

  describe "get_bonus!/1" do
    test "bonus exists" do
      bonus = insert(:bonus)

      assert Interaction.get_bonus!(bonus.id) == bonus
    end

    test "bonus does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Interaction.get_bonus!(123) end
    end
  end

  describe "get_keys_bonus" do
    test "attendee and company both exist" do
      attendee = insert(:attendee)
      company = insert(:company)

      bonus = insert(:bonus, attendee: attendee, company: company)

      bonus =
        bonus
        |> forget(:attendee)
        |> forget(:company)

      assert Interaction.get_keys_bonus(attendee.id, company.id) == bonus
    end

    test "attendee and company both do not exist" do
      assert Interaction.get_keys_bonus(Ecto.UUID.generate(), 123) |> is_nil()
    end
  end

  describe "create_bonus/1" do
    test "with valid data" do
      attendee = insert(:attendee)
      company = insert(:company)

      {:ok, bonus} =
        params_for(:bonus, attendee: attendee, company: company)
        |> Interaction.create_bonus()

      assert Interaction.list_bonuses() == [bonus]
    end

    test "with invalid data" do
      {:error, _changeset} =
        params_for(:bonus)
        |> Interaction.create_bonus()

      assert Interaction.list_bonuses() == []
    end
  end

  describe "update_bonus/1" do
    test "with valid data" do
      bonus1 = insert(:bonus)
      attendee = insert(:attendee)
      company = insert(:company)

      {:ok, bonus2} =
        bonus1
        |> Interaction.update_bonus(params_for(:bonus, attendee: attendee, company: company))

      assert Interaction.list_bonuses() == [bonus2]
    end

    test "with invalid data" do
      bonus = insert(:bonus)

      {:error, _changeset} =
        bonus
        |> Interaction.update_bonus(params_for(:bonus))

      assert Interaction.list_bonuses() == [bonus]
    end
  end

  describe "delete_bonus/1" do
    test "bonus exists" do
      bonus = insert(:bonus)

      {:ok, _bonus} = Interaction.delete_bonus(bonus)

      assert Interaction.list_bonuses() == []
    end
  end

  defp forget(struct, field, cardinality \\ :one) do
    %{
      struct
      | field => %Ecto.Association.NotLoaded{
          __field__: field,
          __owner__: struct.__struct__,
          __cardinality__: cardinality
        }
    }
  end
end
