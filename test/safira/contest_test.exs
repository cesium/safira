defmodule Safira.ContestTest do
  use Safira.DataCase

  alias Safira.Contest

  describe "list_badges/0" do
    test "no badges" do
      assert Contest.list_badges() == []
    end
  end
end
