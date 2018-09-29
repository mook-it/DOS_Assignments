defmodule Gvp.Topologies do
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]}
    }
  end

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def initialise(list, topology) do
    Agent.update(__MODULE__, fn map ->
      map = Gvp.Topo.get_neighbours(list, topology)
      # initialise_helper(map, list, topology) end)
      # IO.inspect(map)
      # [head | tail] = map
      IO.inspect(map)
      map
    end)
  end

  def get_random_neighbour(pid) do
    Agent.get(__MODULE__, fn map -> Enum.random(Map.get(map, pid)) end)
  end

  def get_first() do
    Agent.get(__MODULE__, fn map -> List.first(Map.keys(map)) end)
  end

  def update(pid) do
    Agent.update(__MODULE__, fn map -> remove(map, pid) end)
  end

  # def initialise_helper(map, list, topology) do
  #   numNodes = length(list)
  #
  #   map = %{a: 1}
  #
  #   cond do
  #     topology == "line" ->
  #       neighboursList =
  #         0..(numNodes - 1)
  #         |> Enum.map(fn i ->
  #           cond do
  #             i == 0 -> [Enum.at(list, i + 1)]
  #             i == numNodes - 1 -> [Enum.at(list, i - 1)]
  #             true -> [Enum.at(list, i - 1), Enum.at(list, i + 1)]
  #           end
  #         end)
  #
  #       add_to_map(list, neighboursList, map)
  #       IO.inspect(map)
  #   end
  # end

  # def add_to_map(list, neighboursList, map) do
  #   [head1 | tail1] = list
  #   [head2 | tail2] = neighboursList
  #
  #   if tail1 == [] do
  #   else
  #     Map.put_new(map, head1, head2)
  #     IO.inspect(map)
  #     add_to_map(tail1, tail2, map)
  #   end
  # end

  def remove(map, pid) do
    Map.delete(map, pid)

    Enum.each(map, fn entry ->
      {key, list} = entry
      List.delete(list, pid)
      Map.update!(map, key, fn _ -> list end)
    end)

    map
  end
end
