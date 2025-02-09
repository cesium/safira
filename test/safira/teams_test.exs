defmodule Safira.TeamsTest do
  use Safira.DataCase

  alias Safira.Teams

  describe "teams" do
    alias Safira.Teams.Team

    import Safira.TeamsFixtures

    @invalid_attrs %{name: nil, priority: nil}
    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams([]) == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{name: "some name", priority: 0}

      assert {:ok, %Team{} = team} = Teams.create_team(valid_attrs)
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "team_members" do
    alias Safira.Teams.TeamMember

    import Safira.TeamsFixtures

    @invalid_attrs %{name: nil}

    test "list_team_members/0 returns all team_members" do
      team_member = team_member_fixture()
      assert Teams.list_team_members(nil) == {:ok, [team_member]}
    end

    test "get_team_member!/1 returns the team_member with given id" do
      team_member = team_member_fixture()
      assert Teams.get_team_member!(team_member.id) == team_member
    end

    test "create_team_member/1 with valid data creates a team_member" do
      valid_attrs = %{name: "some name", team_id: team_fixture().id}

      assert {:ok, %TeamMember{} = team_member} = Teams.create_team_member(valid_attrs)
      assert team_member.name == "some name"
    end

    test "create_team_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team_member(@invalid_attrs)
    end

    test "update_team_member/2 with valid data updates the team_member" do
      team_member = team_member_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %TeamMember{} = team_member} =
               Teams.update_team_member(team_member, update_attrs)

      assert team_member.name == "some updated name"
    end

    test "update_team_member/2 with invalid data returns error changeset" do
      team_member = team_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team_member(team_member, @invalid_attrs)
      assert team_member == Teams.get_team_member!(team_member.id)
    end

    test "delete_team_member/1 deletes the team_member" do
      team_member = team_member_fixture()
      assert {:ok, %TeamMember{}} = Teams.delete_team_member(team_member)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team_member!(team_member.id) end
    end

    test "change_team_member/1 returns a team_member changeset" do
      team_member = team_member_fixture()
      assert %Ecto.Changeset{} = Teams.change_team_member(team_member)
    end
  end
end
