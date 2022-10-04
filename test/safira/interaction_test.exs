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
    
  end
end
