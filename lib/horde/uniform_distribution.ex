defmodule Horde.UniformDistribution do
  @behaviour Horde.DistributionStrategy

  @moduledoc """
  Distributes processes to nodes uniformly using a hash ring
  """

  def choose_node(identifier, members) do
    members =
      filter_members(members)
      |> Map.new(fn member -> {member.name, member} end)

    case Enum.count(members) do
      0 ->
        {:error, :no_alive_nodes}

      _not_zero ->
        chosen_member =
          HashRing.new()
          |> HashRing.add_nodes(Map.keys(members))
          |> HashRing.key_to_node(identifier)

        {:ok, Map.get(members, chosen_member)}
    end
  end

  defp filter_members(members) do
    Enum.filter(members, fn
      %{status: :alive} -> true
      _ -> false
    end)
  end

  def has_quorum?(_members), do: true
end
